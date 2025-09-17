import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_app/core/routes/app_routes.dart';
import 'package:project_app/core/widgets/custom_button.dart';
import 'package:project_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        // TODO: Upload image to Firebase Storage
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
              localDataSource: ProfileLocalDataSource(
                sharedPreferences: snapshot.data!,
              ),
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
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Profile'),
                  ),
                  body: state is ProfileLoaded
                      ? SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50.r,
                                    backgroundImage: state.photoUrl != null
                                        ? NetworkImage(state.photoUrl!)
                                        : null,
                                    child: state.photoUrl == null
                                        ? Icon(
                                            Icons.person,
                                            size: 50.r,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: CircleAvatar(
                                      radius: 18.r,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.camera_alt,
                                          size: 18.r,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => _pickImage(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.name,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              TextButton(
                                onPressed: () =>
                                    _updateName(context, state.name),
                                child: const Text('Edit Name'),
                              ),
                              SizedBox(height: 32.h),
                              ListTile(
                                leading: const Icon(Icons.dark_mode),
                                title: const Text('Dark Mode'),
                                trailing: Switch(
                                  value: state.isDarkMode,
                                  onChanged: (value) {
                                    context
                                        .read<ProfileBloc>()
                                        .add(ToggleTheme(value));
                                  },
                                ),
                              ),
                              SizedBox(height: 32.h),
                              CustomButton(
                                text: 'Sign Out',
                                onPressed: () => _showSignOutDialog(context),
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                );
              },
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
