import 'package:equatable/equatable.dart';
import 'package:supabase_flutter_app/models/todo.dart';

abstract class TodoState extends Equatable{
  const TodoState();

  @override
  List<Object?> get props => [];
}
// Trạng thái khởi tạo ban đầu
class TodoInitial extends TodoState {}

// Trạng thái đang tải dữ liệu
class TodoLoadInProgress extends TodoState {}

// Trạng thái tải/thao tác thành công
class TodoLoadSuccess extends TodoState {
  final List<Todo> todos;
  final String filter;
  final String sort;
  final String searchQuery;


  const TodoLoadSuccess({
    this.todos = const [],
    this.filter = 'all',
    this.sort = 'newest',
    this.searchQuery = '',
  });

  TodoLoadSuccess copyWith({
    List<Todo>? todos,
    String? filter,
    String? sort,
    String? searchQuery,
  }) {
    return TodoLoadSuccess(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [todos, filter, sort,searchQuery];
}

// Trạng thái tải/thao tác thất bại
class TodoLoadFailure extends TodoState {
  final String error;
  const TodoLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}