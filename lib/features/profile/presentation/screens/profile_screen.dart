import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_app/core/routes/app_routes.dart';
import 'package:project_app/core/theme/theme_controller.dart';
import 'package:project_app/core/widgets/custom_button.dart';
import 'package:project_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:project_app/features/profile/presentation/widgets/settings_section.dart';
import 'package:project_app/features/profile/presentation/widgets/settings_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        context.read<ProfileBloc>().add(UpdatePhoto(image.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _updateName(BuildContext context, String currentName) async {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<ProfileBloc>().add(UpdateName(name));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(SignOut());
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocProvider(
            create: (context) => ProfileBloc(
              localDataSource:
                  ProfileLocalDataSource(sharedPreferences: snapshot.data!),
            )..add(LoadProfile()),
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is ProfileInitial) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Settings'),
                      elevation: 0,
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          // Profile Section
                          CircleAvatar(
                            radius: 50.r,
                            backgroundImage: state.photoUrl != null
                                ? NetworkImage(state.photoUrl!)
                                : null,
                            child: state.photoUrl == null
                                ? Icon(Icons.person, size: 50.r)
                                : null,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.name ?? 'User',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Account Settings Section
                          SettingsSection(
                            title: 'Account',
                            children: [
                              SettingsTile(
                                icon: Icons.person_outline,
                                title: 'Edit Profile',
                                onTap: () =>
                                    _updateName(context, state.name ?? ''),
                              ),
                              SettingsTile(
                                icon: Icons.photo_camera_outlined,
                                title: 'Change Photo',
                                onTap: () => _pickImage(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Appearance Settings Section
                          SettingsSection(
                            title: 'Appearance',
                            children: [
                              Builder(
                                builder: (context) {
                                  final themeController =
                                      context.read<ThemeController>();
                                  return SettingsTile(
                                    icon: Icons.brightness_4_outlined,
                                    title: 'Dark Mode',
                                    trailing: Switch(
                                      value: state.isDarkMode,
                                      onChanged: (value) {
                                        themeController.setThemeMode(
                                          value
                                              ? ThemeMode.dark
                                              : ThemeMode.light,
                                        );
                                        context
                                            .read<ProfileBloc>()
                                            .add(ToggleTheme(value));
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Other Settings Section
                          SettingsSection(
                            title: 'Other',
                            children: [
                              SettingsTile(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                onTap: () {
                                  // TODO: Implement notifications settings
                                },
                              ),
                              SettingsTile(
                                icon: Icons.language_outlined,
                                title: 'Language',
                                onTap: () {
                                  // TODO: Implement language settings
                                },
                              ),
                              SettingsTile(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                onTap: () {
                                  // TODO: Implement help & support
                                },
                              ),
                              SettingsTile(
                                icon: Icons.info_outline,
                                title: 'About',
                                onTap: () {
                                  // TODO: Implement about screen
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Sign Out Button
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: CustomButton(
                              text: 'Sign Out',
                              onPressed: () => _showSignOutDialog(context),
                              backgroundColor: Colors.red.withOpacity(0.1),
                              textColor: Colors.red,
                            ),
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  );
                }

                // Loading State or Error State
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          );
        }

        // SharedPreferences not yet loaded
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
