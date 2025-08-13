import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalAuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // Simula registro
  Future<bool> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Buscar usuários existentes
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = json.decode(usersJson);

    // Verificar se email já existe
    if (users.any((user) => user['email'] == email)) {
      throw Exception('Email já cadastrado');
    }

    // Adicionar novo usuário
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'password': password, // Em produção seria hash
      'createdAt': DateTime.now().toIso8601String(),
    };

    users.add(newUser);
    await prefs.setString(_usersKey, json.encode(users));

    // Fazer login automático após registro
    await prefs.setString(_currentUserKey, json.encode(newUser));
    return true;
  }

  // Simula login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = json.decode(usersJson);

    // Buscar usuário
    try {
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );

      // Salvar usuário atual
      await prefs.setString(_currentUserKey, json.encode(user));
      return Map<String, dynamic>.from(user);
    } catch (e) {
      throw Exception('Email ou senha incorretos');
    }
  }

  // Verificar se está logado
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);

    if (userJson != null) {
      return Map<String, dynamic>.from(json.decode(userJson));
    }
    return null;
  }

  // Verificar se está logado (síncrono para build)
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Atualizar perfil
  Future<void> updateProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();

    if (currentUser != null) {
      currentUser['name'] = name;
      currentUser['email'] = email;
      currentUser['updatedAt'] = DateTime.now().toIso8601String();

      // Atualizar usuário atual
      await prefs.setString(_currentUserKey, json.encode(currentUser));

      // Atualizar na lista de usuários
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> users = json.decode(usersJson);

      final userIndex = users.indexWhere(
        (user) => user['id'] == currentUser['id'],
      );
      if (userIndex != -1) {
        users[userIndex] = currentUser;
        await prefs.setString(_usersKey, json.encode(users));
      }
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Deletar conta
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = await getCurrentUser();

    if (currentUser != null) {
      // Remover da lista de usuários
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> users = json.decode(usersJson);
      users.removeWhere((user) => user['id'] == currentUser['id']);
      await prefs.setString(_usersKey, json.encode(users));

      // Fazer logout
      await logout();
    }
  }
}
