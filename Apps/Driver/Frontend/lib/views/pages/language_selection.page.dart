import 'package:flutter/material.dart';
import 'package:fuodz/services/language.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:provider/provider.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? selectedLanguage = 'en';

  void _continueToWelcome() async {
    try {
      // Save selected language
      final languageService = Provider.of<LanguageService>(context, listen: false);
      await languageService.changeLanguage(selectedLanguage!);
      
      // Mark first time as completed
      await AuthServices.firstTimeCompleted();
      
      // Navigate to welcome page
      Navigator.of(context).pushReplacementNamed('/welcome');
    } catch (e) {
      print('Navigation error: $e');
      // Fallback: show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Navigation Error'),
          content: Text('Could not navigate to welcome page: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive mobile design - adapts to actual screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, // 4% of screen width
              vertical: screenHeight * 0.015, // 1.5% of screen height
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
                
                // Header with close button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Color(0xFFE91E63),
                        size: screenWidth * 0.06, // 6% of screen width
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.02), // 2% of screen width
                      constraints: BoxConstraints(
                        minWidth: screenWidth * 0.1, // 10% of screen width
                        minHeight: screenWidth * 0.1,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Select your preferred language',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // 4% of screen width
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.004), // 0.4% of screen height
                          Text(
                            'You can change language later from the settings menu',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03, // 3% of screen width
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.1), // Balance the close button
                  ],
                ),
                
                SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                
                // Language Grid (Mobile Layout)
                Expanded(
                  child: Consumer<LanguageService>(
                    builder: (context, languageService, child) {
                      final languages = languageService.allLanguages;
                      
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: screenWidth * 0.02, // 2% of screen width
                          mainAxisSpacing: screenHeight * 0.01, // 1% of screen height
                        ),
                        itemCount: languages.length,
                        itemBuilder: (context, index) {
                          final languageCode = languages.keys.elementAt(index);
                          final language = languages[languageCode]!;
                          final isSelected = selectedLanguage == languageCode;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLanguage = languageCode;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                border: isSelected ? Border.all(
                                  color: Color(0xFFE91E63),
                                  width: 2,
                                ) : null,
                              ),
                              child: Stack(
                                children: [
                                  // Centered content
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Flag - Centered
                                        Text(
                                          language['flag']!,
                                          style: TextStyle(fontSize: screenWidth * 0.075), // 7.5% of screen width
                                          textAlign: TextAlign.center,
                                        ),
                                        
                                        SizedBox(height: screenHeight * 0.007), // 0.7% of screen height
                                        
                                        // Language name - Centered
                                        Text(
                                          language['name']!,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03, // 3% of screen width
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Selection indicator - Positioned at top-right
                                  if (isSelected)
                                    Positioned(
                                      top: screenHeight * 0.01, // 1% of screen height
                                      right: screenWidth * 0.02, // 2% of screen width
                                      child: Container(
                                        width: screenWidth * 0.04, // 4% of screen width
                                        height: screenWidth * 0.04,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE91E63),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: screenWidth * 0.03, // 3% of screen width
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06, // 6% of screen height
                  child: ElevatedButton(
                    onPressed: _continueToWelcome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // 4% of screen width
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
              ],
            ),
          ),
        ),
      ),
    );
  }
}
