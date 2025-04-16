import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/bloc/todo/todo_bloc.dart';
import 'package:supabase_flutter_app/bloc/todo/todo_event.dart';
import 'package:supabase_flutter_app/bloc/todo/todo_state.dart';
import 'package:supabase_flutter_app/presentation/auth/login_page.dart';
import 'package:supabase_flutter_app/models/todo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  final _taskController = TextEditingController();

  // List<Todo> _todos = [];
  // bool _isLoading = false;

  // String _filterBy = 'all';
  // String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    // _fetchTodos();
  }

  // Future<void> _fetchTodos() async {
  //   if (mounted) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //   } else {
  //     return;
  //   }
  //
  //   try {
  //     final userId = _supabase.auth.currentUser?.id;
  //     if (userId == null) {
  //       throw 'Người dùng chưa đăng nhập';
  //     }
  //
  //     var query = _supabase.from('todos').select().eq('user_id', userId);
  //
  //     if (_filterBy == 'completed') {
  //       query = query.eq('status', 'completed');
  //     } else if (_filterBy == 'incomplete') {
  //       query = query.neq('status', 'completed');
  //     }
  //
  //     final finalQuery = _sortBy == 'newest'
  //         ? query.order('created_at', ascending: false)
  //         : query.order('created_at', ascending: true);
  //
  //     final response = await finalQuery;
  //
  //     if (response == null) {
  //       throw 'Không thể tải danh sách công việc.';
  //     }
  //
  //     if (mounted) {
  //       setState(() {
  //         _todos =
  //             (response as List).map((todo) => Todo.fromJson(todo)).toList();
  //       });
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error fetching todos: $e')),
  //     );
  //     if (mounted) {
  //       setState(() {
  //         _todos = [];
  //       });
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }
  //
  // Future<void> _addTodo() async {
  //   if (_taskController.text.isEmpty) return;
  //   final userId = _supabase.auth.currentUser?.id;
  //
  //   if (userId == null) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Vui lòng đăng nhập')),
  //       );
  //     }
  //     return;
  //   }
  //
  //   try {
  //     await _supabase.from('todos').insert({
  //       'user_id': userId,
  //       'task': _taskController.text.trim(),
  //       'status': 'pending',
  //     });
  //
  //     _taskController.clear();
  //     _fetchTodos();
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error adding todo: $e')),
  //     );
  //   }
  // }
  //
  // Future<void> _toggleTodoCompletion(Todo todo) async {
  //   final userId = _supabase.auth.currentUser?.id;
  //   if (userId == null || userId != todo.userId) return;
  //
  //   try {
  //     final newStatus = todo.status == 'completed' ? 'pending' : 'completed';
  //     await _supabase
  //         .from('todos')
  //         .update({'status': newStatus}).eq('id', todo.id);
  //
  //     _fetchTodos();
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error updating todo: $e')),
  //     );
  //   }
  // }
  //
  // Future<void> _deleteTodo(String id) async {
  //   final userId = _supabase.auth.currentUser?.id;
  //   if (userId == null) return;
  //
  //   try {
  //     await _supabase.from('todos').delete().eq('id', id);
  //     _fetchTodos();
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error deleting todo: $e')),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(supabaseClient: Supabase.instance.client)..add(TodosFetched()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
          actions: [
            BlocBuilder<TodoBloc, TodoState>(
              buildWhen: (previous, current) =>
              previous is! TodoLoadSuccess || current is! TodoLoadSuccess ||
                  previous.filter != current.filter,
              builder: (context, state) {
                String currentFilter = 'all';
                if (state is TodoLoadSuccess) {
                  currentFilter = state.filter;
                }
                return DropdownButton<String>(
                  value: currentFilter,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<TodoBloc>().add(FilterUpdated(filter: value));
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'incomplete', child: Text('Incomplete')),
                  ],
                );
              },
            ),
            BlocBuilder<TodoBloc, TodoState>(
              buildWhen: (previous, current) =>
              previous is! TodoLoadSuccess || current is! TodoLoadSuccess ||
                  previous.sort != current.sort,
              builder: (context, state) {
                String currentSort = 'newest';
                if (state is TodoLoadSuccess) {
                  currentSort = state.sort;
                }
                return DropdownButton<String>(
                  value: currentSort,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<TodoBloc>().add(SortUpdated(sort: value));
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _supabase.auth.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            // --- Trường hợp đang tải ---
            if (state is TodoLoadInProgress || state is TodoInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            // --- Trường hợp tải lỗi ---
            if (state is TodoLoadFailure) {
              return Center(
                child: Text('Lỗi tải dữ liệu: ${state.error}'),
              );
            }
            // --- Trường hợp tải thành công ---
            if (state is TodoLoadSuccess) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: const InputDecoration(labelText: 'New Task'),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                context.read<TodoBloc>().add(TodoAdded(task: value));
                                _taskController.clear();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final task = _taskController.text.trim();
                            if (task.isNotEmpty) {
                              context.read<TodoBloc>().add(TodoAdded(task: task));
                              _taskController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // --- Phần danh sách Todos ---
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.todos.length,
                      itemBuilder: (context, index) {
                        final todo = state.todos[index];
                        return ListTile(
                          title: Text(
                              todo.task,
                              style: TextStyle(
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                color: todo.isCompleted ? Colors.grey : null,
                              ),
                          ),
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (value) {
                              // Gửi event ToggleTodo đến BLoC
                              context.read<TodoBloc>().add(TodoToggled(todo: todo));
                            },
                          ),
                          trailing: Row( // Dùng Row để chứa nhiều nút
                            mainAxisSize: MainAxisSize.min, // Để Row chỉ chiếm đủ không gian cần thiết
                            children: [
                              // --- Nút Sửa ---
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue), // Icon sửa
                                onPressed: () {
                                  // Hiện dialog để sửa task
                                  _showEditTodoDialog(context, todo);
                                },
                              ),
                              // --- Nút Xóa ---
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  // Xác nhận trước khi xóa (tùy chọn)
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: Text('Bạn có chắc muốn xóa công việc "${todo.task}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                            context.read<TodoBloc>().add(TodoDeleted(id: todo.id));
                                          },
                                          child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  // context.read<TodoBloc>().add(TodoDeleted(id: todo.id)); // Hoặc xóa trực tiếp
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Trạng thái không xác định'));
          },
        ),
        bottomNavigationBar: IconButton(onPressed: (){}, icon: Icon(Icons.ice_skating_outlined)),
      ),
    );
  }
}

void _showEditTodoDialog(BuildContext context, Todo todo) {
  final TextEditingController dialogTaskController = TextEditingController(text: todo.task);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Sửa công việc'),
        content: TextField(
          controller: dialogTaskController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập nội dung mới'),
          onSubmitted: (value) {
            _saveEditedTodo(context, todo.id, dialogTaskController.text, dialogContext);
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Hủy'),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
          TextButton(
            child: const Text('Lưu'),
            onPressed: () {
              _saveEditedTodo(context, todo.id, dialogTaskController.text, dialogContext);
            },
          ),
        ],
      );
    },
  ).then((_) {
  });
}

// Hàm tách ra để xử lý việc lưu
void _saveEditedTodo(BuildContext blocContext, String todoId, String newTask, BuildContext dialogContext) {
  final trimmedTask = newTask.trim();
  if (trimmedTask.isNotEmpty) {
    blocContext.read<TodoBloc>().add(
      TodoUpdated(id: todoId, newTask: trimmedTask),
    );
  }
  Navigator.pop(dialogContext);
}