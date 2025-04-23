import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(supabaseClient: Supabase.instance.client)..add(TodosFetched()),
      child: Builder(
          builder: (providerContext) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('To-Do List'),
                actions: [
                  // Filter Dropdown
                  BlocBuilder<TodoBloc, TodoState>(
                    buildWhen: (previous, current) =>
                    previous is! TodoLoadSuccess || current is! TodoLoadSuccess ||
                        previous.filter != current.filter,
                    builder: (context, state) {
                      String currentFilter = 'all';
                      if (state is TodoLoadSuccess) {
                        currentFilter = state.filter;
                      }
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentFilter,
                          icon: const Icon(Icons.filter_list, color: Colors.black),
                          style: const TextStyle(color: Colors.black),
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
                        ),
                      );
                    },
                  ),
                  // Sort Dropdown
                  BlocBuilder<TodoBloc, TodoState>(
                    buildWhen: (previous, current) =>
                    previous is! TodoLoadSuccess || current is! TodoLoadSuccess ||
                        previous.sort != current.sort,
                    builder: (context, state) {
                      String currentSort = 'newest';
                      if (state is TodoLoadSuccess) {
                        currentSort = state.sort;
                      }
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentSort,
                          icon: const Icon(Icons.sort, color: Colors.black),
                          style: const TextStyle(color: Colors.black),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<TodoBloc>().add(SortUpdated(sort: value));
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Newest')),
                            DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                          ],
                        ),
                      );
                    },
                  ),
                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await _supabase.auth.signOut();
                      if (!providerContext.mounted) return;
                      Navigator.pushReplacement(
                        providerContext,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                  children: [
                    // Search TextField
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm công việc...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              providerContext.read<TodoBloc>().add(const SearchQueryChanged(query: ''));
                              FocusScope.of(providerContext).unfocus();
                            },
                          )
                              : null,
                        ),
                        onChanged: (value) {
                          providerContext.read<TodoBloc>().add(SearchQueryChanged(query: value));
                        },
                      ),
                    ),
                    // List View
                    Expanded(
                      child: BlocBuilder<TodoBloc, TodoState>(
                        builder: (listContext, state) {
                          if (state is TodoLoadInProgress || state is TodoInitial) {
                            return Center(
                              child: LottieBuilder.asset(
                                'assets/animations/loading.json',
                                width: 80,
                                height: 80,
                              ),
                            );
                          }
                          if (state is TodoLoadFailure) {
                            return Center(
                              child: Text('Lỗi tải dữ liệu: ${state.error}'),
                            );
                          }
                          if (state is TodoLoadSuccess) {
                            if (state.todos.isEmpty && state.searchQuery.isNotEmpty) {
                              return const Center(child: Text('Không tìm thấy công việc nào.'));
                            }
                            if (state.todos.isEmpty && state.searchQuery.isEmpty) {
                              return const Center(child: Text('Chưa có công việc nào. Hãy thêm mới!'));
                            }
                            return ListView.builder(
                              itemCount: state.todos.length,
                              itemBuilder: (itemContext, index) {
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
                                      itemContext.read<TodoBloc>().add(TodoToggled(todo: todo));
                                    },
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          _showEditTodoDialog(itemContext, todo);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () {
                                          showDialog(
                                            context: itemContext,
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
                                                    itemContext.read<TodoBloc>().add(TodoDeleted(id: todo.id));
                                                  },
                                                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(child: Text('Trạng thái không xác định'));
                        },
                      ),
                    ),
                  ]
              ),
              floatingActionButton: Builder(
                  builder: (fabContext) {
                    return FloatingActionButton(
                      onPressed: () => _showAddTaskDialog(fabContext),
                      tooltip: 'Thêm công việc mới',
                      child: const Icon(Icons.add),
                    );
                  }
              ),
            );
          }
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

void _showAddTaskDialog(BuildContext context) {
  final TextEditingController dialogTaskController = TextEditingController();
  showDialog(
    context: context, // Dùng context được truyền vào để show dialog
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Thêm công việc mới'),
        content: TextField(
          controller: dialogTaskController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập nội dung công việc'),
          onSubmitted: (value) {
            final task = dialogTaskController.text.trim();
            if (task.isNotEmpty) {
              // Dùng context gốc để đọc Bloc
              context.read<TodoBloc>().add(TodoAdded(task: task));
              Navigator.pop(dialogContext);
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text('Thêm'),
            onPressed: () {
              final task = dialogTaskController.text.trim();
              if (task.isNotEmpty) {
                // Dùng context gốc để đọc Bloc
                context.read<TodoBloc>().add(TodoAdded(task: task));
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      );
    },
  );
}

void _saveEditedTodo(BuildContext blocContext, String todoId, String newTask, BuildContext dialogContext) {
  final trimmedTask = newTask.trim();
  if (trimmedTask.isNotEmpty) {
    blocContext.read<TodoBloc>().add(
      TodoUpdated(id: todoId, newTask: trimmedTask),
    );
  }
  Navigator.pop(dialogContext);
}

