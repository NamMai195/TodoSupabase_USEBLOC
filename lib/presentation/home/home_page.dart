import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  List<Todo> _todos = [];
  bool _isLoading = false;

  String _filterBy = 'all';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    } else {
      return;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw 'Người dùng chưa đăng nhập';
      }

      var query = _supabase.from('todos').select().eq('user_id', userId);

      if (_filterBy == 'completed') {
        query = query.eq('status', 'completed');
      } else if (_filterBy == 'incomplete') {
        query = query.neq('status', 'completed');
      }

      final finalQuery = _sortBy == 'newest'
          ? query.order('created_at', ascending: false)
          : query.order('created_at', ascending: true);

      final response = await finalQuery;

      if (response == null) {
        throw 'Không thể tải danh sách công việc.';
      }

      if (mounted) {
        setState(() {
          _todos =
              (response as List).map((todo) => Todo.fromJson(todo)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching todos: $e')),
      );
      if (mounted) {
        setState(() {
          _todos = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addTodo() async {
    if (_taskController.text.isEmpty) return;
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
      }
      return;
    }

    try {
      await _supabase.from('todos').insert({
        'user_id': userId,
        'task': _taskController.text.trim(),
        'status': 'pending',
      });

      _taskController.clear();
      _fetchTodos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding todo: $e')),
      );
    }
  }

  Future<void> _toggleTodoCompletion(Todo todo) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId != todo.userId) return;

    try {
      final newStatus = todo.status == 'completed' ? 'pending' : 'completed';
      await _supabase
          .from('todos')
          .update({'status': newStatus}).eq('id', todo.id);

      _fetchTodos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }

  Future<void> _deleteTodo(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('todos').delete().eq('id', id);
      _fetchTodos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          DropdownButton<String>(
            value: _filterBy,
            onChanged: (value) {
              setState(() {
                _filterBy = value!;
                _fetchTodos();
              });
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'incomplete', child: Text('Incomplete')),
            ],
          ),
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
                _fetchTodos();
              });
            },
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Newest First')),
              DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
            ],
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration:
                              const InputDecoration(labelText: 'New Task'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTodo,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return ListTile(
                        title: Text(todo.task),
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (value) => _toggleTodoCompletion(todo),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTodo(todo.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
