class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  bool isLoggedIn = false;
  String userName = 'Emprendedor';
  String userEmail = '';
  String userPlan = 'Free'; // Free, Emprendedor, Pro

  void login(String name, String email, {String plan = 'Free'}) {
    isLoggedIn = true;
    userName = name;
    userEmail = email;
    userPlan = plan;
  }

  void logout() {
    isLoggedIn = false;
    userName = 'Emprendedor';
    userEmail = '';
    userPlan = 'Free';
  }

  String get initials {
    if (userName.isEmpty) return 'U';
    List<String> parts = userName.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName.length > 1 ? userName.substring(0, 2).toUpperCase() : userName[0].toUpperCase();
  }
}
