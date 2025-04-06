abstract class TodoEvent {}

class FetchTodos extends TodoEvent {}

class AddTodo extends TodoEvent{}

class ToggleTodoCompletion extends TodoEvent{}

class DeleteTodo extends TodoEvent{}