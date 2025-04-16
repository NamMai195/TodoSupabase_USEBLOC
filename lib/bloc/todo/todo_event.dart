import 'package:equatable/equatable.dart';
import 'package:supabase_flutter_app/models/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

// Event để yêu cầu tải danh sách Todos (có thể kèm filter/sort)
class TodosFetched extends TodoEvent {}

// Event để thêm Todo mới
class TodoAdded extends TodoEvent {
  final String task;
  const TodoAdded({required this.task});

  @override
  List<Object> get props => [task];
}

// Event để thay đổi trạng thái hoàn thành của Todo
class TodoToggled extends TodoEvent {
  final Todo todo;
  const TodoToggled({required this.todo});

  @override
  List<Object> get props => [todo];
}

// Event để xóa Todo
class TodoDeleted extends TodoEvent {
  final String id;
  const TodoDeleted({required this.id});

  @override
  List<Object> get props => [id];
}

// Event cập nhật bộ lọc
class FilterUpdated extends TodoEvent {
  final String filter;
  const FilterUpdated({required this.filter});

  @override
  List<Object> get props => [filter];
}

// Event cập nhật sắp xếp
class SortUpdated extends TodoEvent {
  final String sort;
  const SortUpdated({required this.sort});

  @override
  List<Object> get props => [sort];
}
//update
class TodoUpdated extends TodoEvent {
  final String id;
  final String newTask;
  const TodoUpdated({required this.id, required this.newTask});

  @override
  List<Object> get props => [id, newTask];
}