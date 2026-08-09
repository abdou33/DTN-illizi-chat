import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/core/utils/ui_utils.dart';
import 'package:dtn_chat/data/services/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/chat_service.dart';
import 'conversation_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _auth = AuthService();
  final _chat = ChatService();
  final _searchCtrl = TextEditingController();
  List<UserModel> _results = [];
  List<UserModel> _contacts_results = [];
  bool _searching = false;

  final dio = Dio();
  Timer? _searchDebounce;
  var logger = Logger();
  @override
  void initState() {
    getcontacts();
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final response = await dio.get(
        "${AppUrls.api_url}/api/search",
        data: {'query': _searchCtrl.text},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          validateStatus: (status) => true, // accept all codes
        ),
      );
      // logger.i(
      //   "result type: ${response.data.runtimeType}: statusCode2: ${response.statusCode}: search results: ${response.data}",
      // );

      if (response.statusCode == 200) {
        setState(() {
          _results = (response.data as List)
              .map((e) => UserModel.fromMap(e))
              .toList();
        });
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      if (mounted)
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
    // final users = await _auth.searchUsers(query.trim());
    if (mounted)
      setState(() {
        _searching = false;
      });
  }

  Future<void> _openChat(UserModel user) async {
    // final chatId = await _chat.getOrCreateChat(user.id);
    try {
      final response = await dio.post(
        "${AppUrls.api_url}/api/conversations/private",
        data: {'user_id': user.id},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          validateStatus: (status) => true, // accept all codes
        ),
      );
      // logger.i("response: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              otherUser: user,
              chatId: "${response.data["id"]}",
            ),
          ),
        );
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      if (mounted)
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
    }
    if (!mounted) return;
  }

  void getcontacts() async {
    try {
      final contacts = await ContactsService.getPhoneNumbers();
      if (contacts.isNotEmpty) {
        final response = await dio.post(
          "${AppUrls.api_url}/api/contacts/sync",
          data: {"contacts": contacts},
          options: Options(
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer ${AuthService.token}",
            },
            validateStatus: (status) => true,
          ),
        );
        if (!mounted) return;
        if (response.statusCode == 200) {
          setState(() {
            _contacts_results = (response.data as List)
                .map((e) => UserModel.fromMap(e))
                .toList();
          });
        } else {
          throw Exception(
            response.data is Map<String, dynamic>
                ? response.data["error"]?.toString() ??
                      "Request failed with status ${response.statusCode}"
                : response.data.toString(),
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosGroupedBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Chat',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                _searchDebounce?.cancel();

                _searchDebounce = Timer(
                  const Duration(milliseconds: 400),
                  () => _search(value),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(
                  AppIcons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.iosGroupedBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_searchCtrl.text.isNotEmpty) _buildSearchResults(),

                if (_contacts_results.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      spacing: 10,
                      children: [
                        const Icon(
                          AppIcons.contacts,
                          color: AppColors.textSecondary,
                        ),
                        const Text("your Contacts on DTN chat:"),
                      ],
                    ),
                  ),
                  _buildContactResults(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return _buildUserList(_results);
  }

  Widget _buildContactResults() {
    if (_contacts_results.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildUserList(_contacts_results);
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: users.map((user) {
        return ListTile(
          leading: UserAvatar(user: user, radius: 24),
          title: Text(user.name),
          subtitle: Text(
            user.phonenumber,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () => _openChat(user),
        );
      }).toList(),
    );
  }
}
