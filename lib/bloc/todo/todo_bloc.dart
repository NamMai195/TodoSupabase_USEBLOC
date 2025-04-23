import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/models/todo.dart';
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
    on<TodoUpdated>(_onTodoUpdated);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onTodosFetched(
      TodosFetched event,
      Emitter<TodoState> emit,
      ) async {
    String currentFilter = 'all';
    String currentSort = 'newest';
    String currentSearchQuery = '';
    if (state is TodoLoadSuccess) {
      final successState = state as TodoLoadSuccess;
      currentFilter = successState.filter;
      currentSort = successState.sort;
      currentSearchQuery = successState.searchQuery;
    }

    if (state is! TodoLoadInProgress) {
      emit(TodoLoadInProgress());
    }

    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'Người dùng chưa đăng nhập';

      var query = _supabaseClient.from('todos').select().eq('user_id', userId);

      if (currentSearchQuery.trim().isNotEmpty) {
        query = query.ilike('task', '%${currentSearchQuery.trim()}%');
      }

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
        todos: todos,
        filter: currentFilter,
        sort: currentSort,
        searchQuery: currentSearchQuery,
      ));
    } catch (e) {
      print('Error fetching todos: $e');
      emit(TodoLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<TodoState> emit,
      ) async {
    final currentState = state;
    if (currentState is TodoLoadSuccess) {
      emit(currentState.copyWith(searchQuery: event.query.trim()));
      add(TodosFetched());
    }
  }

  Future<void> _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw 'Người dùng chưa đăng nhập';
      final taskTrimmed = event.task.trim();
      if (taskTrimmed.isEmpty) return;

      await _supabaseClient.from('todos').insert({
        'user_id': userId,
        'task': taskTrimmed,
        'status': 'pending',
      });
      add(TodosFetched());
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> _onTodoToggled(
      TodoToggled event, Emitter<TodoState> emit) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null || userId != event.todo.userId) {
        print('Unauthorized toggle attempt or user not logged in.');
        return;
      };

      final newStatus =
      event.todo.status == 'completed' ? 'pending' : 'completed';
      await _supabaseClient
          .from('todos')
          .update({'status': newStatus})
          .eq('id', event.todo.id)
          .eq('user_id', userId);

      add(TodosFetched());
    } catch (e) {
      print('Error toggling todo: $e');
    }
  }

  Future<void> _onTodoDeleted(
      TodoDeleted event, Emitter<TodoState> emit) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;

      await _supabaseClient
          .from('todos')
          .delete()
          .eq('id', event.id)
          .eq('user_id', userId);

      add(TodosFetched());
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

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

  Future<void> _onTodoUpdated(
      TodoUpdated event,
      Emitter<TodoState> emit,
      ) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return;
      final newTaskTrimmed = event.newTask.trim();
      if (newTaskTrimmed.isEmpty) return;

      await _supabaseClient
          .from('todos')
          .update({'task': newTaskTrimmed})
          .eq('id', event.id)
          .eq('user_id', userId);

      add(TodosFetched());
    } catch (e) {
      print('Error updating todo: $e');
    }
  }
}