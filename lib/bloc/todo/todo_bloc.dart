import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/models/todo.dart'; // Import model
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final SupabaseClient _supabaseClient;
  TodoBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(TodoInitial()) {
    on<TodosFetched>(_onTodosFetched);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<FilterUpdated>(_onFilterUpdated);
    on<SortUpdated>(_onSortUpdated);
  }

// xử lý sự kiện lấy danh sách công việc
  Future<void> _onTodosFetched(
    TodosFetched event,
    Emitter<TodoState> emit,
  ) async {
    String currentFilter = 'all';
    String currentSort = 'newest';
    if (state is TodoLoadSuccess) {
      currentFilter = (state as TodoLoadSuccess).filter;
      currentSort = (state as TodoLoadSuccess).sort;
    }

    emit(TodoLoadInProgress());
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'Người dùng chưa đăng nhập';

      var query = _supabaseClient.from('todos').select().eq('user_id', userId);

      if (currentFilter == 'completed') {
        query = query.eq('status', 'completed');
      } else if (currentFilter == 'incomplete') {
        query = query.neq('status', 'completed');
      }

      final finalQuery = currentSort == 'newest'
          ? query.order('created_at', ascending: false)
          : query.order('created_at', ascending: true);

      final response = await finalQuery;

      final todos =
          (response as List).map((todo) => Todo.fromJson(todo)).toList();

      emit(TodoLoadSuccess(
          todos: todos, filter: currentFilter, sort: currentSort));
    } catch (e) {
      emit(TodoLoadFailure(error: e.toString()));
    }
  }

  // --- Handler cho việc thêm Todo ---
  Future<void> _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'Người dùng chưa đăng nhập';
      if (event.task.isEmpty) return;

      await _supabaseClient.from('todos').insert({
        'user_id': userId,
        'task': event.task,
        'status': 'pending',
      });
      add(TodosFetched());
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  //Toggle
  Future<void> _onTodoToggled(
      TodoToggled event, Emitter<TodoState> emit) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null || userId != event.todo.userId) return;

      final newStatus =
          event.todo.status == 'completed' ? 'pending' : 'completed';
      await _supabaseClient
          .from('todos')
          .update({'status': newStatus}).eq('id', event.todo.id);

      add(TodosFetched());
    } catch (e) {
      print('Error toggling todo: $e');
    }
  }

//delete
  Future<void> _onTodoDeleted(
      TodoDeleted event, Emitter<TodoState> emit) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      await _supabaseClient.from('todos').delete().eq('id', event.id);

      add(TodosFetched());
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

//Filter
  Future<void> _onFilterUpdated(
      FilterUpdated event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is TodoLoadSuccess) {
      emit(currentState.copyWith(filter: event.filter));
      add(TodosFetched());
    } else {
      add(TodosFetched());
    }
  }

//Sort
  Future<void> _onSortUpdated(
      SortUpdated event, Emitter<TodoState> emit) async {
    final currentState = state;
    if (currentState is TodoLoadSuccess) {
      emit(currentState.copyWith(sort: event.sort));
      add(TodosFetched());
    } else {
      add(TodosFetched());
    }
  }
}
