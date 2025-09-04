import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      title: "My Profile",
      body: Container(
        padding: EdgeInsets.all(20),
        child: VStack(
          [
            // Quick Actions
            Text(
              "Quick Actions",
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).py16(),
            
            HStack(
              [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.emergency,
                    label: "SOS",
                    backgroundColor: AppColor.classyError,
                    onTap: () => _showSOSDialog(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.notifications,
                    label: "Notifications",
                    backgroundColor: AppColor.classyInfo,
                    onTap: () {
                      // Navigate to notifications
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.report_problem,
                    label: "Complaints",
                    backgroundColor: AppColor.classyWarning,
                    onTap: () {
                      // Navigate to complaints
                    },
                  ),
                ),
              ],
            ).py16(),
            
            // Profile Sections
            VStack(
              [
                _buildProfileSection(
                  icon: Icons.directions_car,
                  title: "My Vehicles",
                  subtitle: "Toyota Premio, UBA 123X",
                  backgroundColor: AppColor.classyPrimary.withOpacity(0.1),
                  onTap: () {
                    // Navigate to vehicles
                  },
                ),
                
                _buildProfileSection(
                  icon: Icons.description,
                  title: "Documents",
                  subtitle: "Verified",
                  backgroundColor: AppColor.classySuccess.withOpacity(0.1),
                  onTap: () {
                    // Navigate to documents
                  },
                ),
                
                _buildProfileSection(
                  icon: Icons.logout,
                  title: "Logout",
                  subtitle: "",
                  backgroundColor: AppColor.classyError.withOpacity(0.1),
                  onTap: () => _showLogoutDialog(),
                ),
              ],
            ).py16(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: VStack(
          [
            Icon(
              icon,
              color: backgroundColor == AppColor.classyError 
                  ? AppColor.textWhite 
                  : backgroundColor == AppColor.classyInfo 
                      ? AppColor.classyInfo 
                      : AppColor.classyWarning,
              size: 30,
            ).py8(),
            Text(
              label,
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: HStack(
          [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColor.classyPrimary,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: VStack(
                [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColor.classySuccess,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
                crossAlignment: CrossAxisAlignment.start,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColor.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: HStack(
          [
            Icon(
              Icons.emergency,
              color: AppColor.classyError,
              size: 24,
            ),
            SizedBox(width: 8),
            Text("Emergency SOS"),
          ],
        ),
        content: Text(
          "Are you sure you want to send an SOS alert? This will notify emergency support immediately.",
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle SOS
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.classyError,
              foregroundColor: AppColor.textWhite,
            ),
            child: Text("Send SOS"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: HStack(
          [
            Icon(
              Icons.logout,
              color: AppColor.classyError,
              size: 24,
            ),
            SizedBox(width: 8),
            Text("Logout"),
          ],
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.classyError,
              foregroundColor: AppColor.textWhite,
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
