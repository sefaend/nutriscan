/// Ekranlarda görünen tüm yazılar burada. İleride dil desteği eklenirse tek yer.
class AppStrings {
  AppStrings._();

  static const String appName = 'NutriScan';

  // Auth
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String or = 'or';
  static const String emailHint = 'Enter your email...';
  static const String passwordHint = '******';
  static const String usernameHint = 'Username';
  static const String signUpEmailHint = 'Enter your email...';
  static const String signUpPasswordHint = 'Password';
  static const String passwordAgainHint = 'Password Again';
  static const String noAccount = "I don't have an account!";
  static const String haveAccount = 'Do you have an account?';
  static const String genericError = 'Something went wrong. Please try again.';

  // Home
  static const String todaySearches = 'Today Searches';
  static const String history = 'History';
  static const String noScansYet = 'No scans yet.';

  // Profile
  static const String allergies = 'Allergies';
  static const String dietaryPreference = 'Dietary Preference';
  static const String suggestedForYou = 'Suggested For You';
  static const String suggestedSubtitle =
      'Products you may prefer, based on your allergies and diet.';
  static const String settings = 'Settings';
  static const String signOut = 'Sign out';
  static const String add = 'Add';
  static const String cancel = 'Cancel';

  // Validation
  static const String requiredField = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email.';
  static const String shortPassword = 'Password must be at least 6 characters.';
  static const String shortUsername = 'Username must be at least 3 characters.';
  static const String passwordsDontMatch = 'Passwords do not match.';
}
