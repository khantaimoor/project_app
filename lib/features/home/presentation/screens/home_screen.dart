import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/core/routes/app_routes.dart';
import 'package:project_app/core/widgets/custom_bottom_bar.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_bloc.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_state.dart';
import 'package:project_app/features/home/presentation/widgets/countdown_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CountdownBloc()..add(LoadCountdownEvents()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180.h,
              floating: true,
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60.h),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi Taimoor 👋',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Track your special moments',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person_outline,
                              color: Colors.greenAccent),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: BlocBuilder<CountdownBloc, CountdownState>(
                builder: (context, state) {
                  if (state is CountdownLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        ),
                      ),
                    );
                  }

                  if (state is CountdownLoaded) {
                    if (state.events.isEmpty) {
                      return SliverFillRemaining(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 80.h,
                              color: Colors.grey[700],
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'No Events Yet',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Create your first countdown',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = state.events[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: CountdownCard(
                              event: event,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.eventDetail,
                                  arguments: event,
                                ).then((_) {
                                  context
                                      .read<CountdownBloc>()
                                      .add(LoadCountdownEvents());
                                });
                              },
                              onDelete: () {
                                context.read<CountdownBloc>().add(
                                      DeleteCountdownEvent(event.id),
                                    );
                              },
                              onNotificationToggle: (enabled) {
                                context.read<CountdownBloc>().add(
                                      ToggleNotification(
                                        eventId: event.id,
                                        enabled: enabled,
                                      ),
                                    );
                              },
                            ),
                          );
                        },
                        childCount: state.events.length,
                      ),
                    );
                  }

                  if (state is CountdownError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.h,
                              color: Colors.redAccent,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Oops! Something went wrong',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: CustomBottomBar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            if (index == -1) {
              Navigator.pushNamed(
                context,
                AppRoutes.addEvent,
              ).then((_) {
                context.read<CountdownBloc>().add(LoadCountdownEvents());
              });
              return;
            }

            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 3: // Settings
                Navigator.pushNamed(context, AppRoutes.profile);
                break;
              // Add other cases as needed
              case 2: // Calendar
                // TODO: Implement calendar view
                break;
              case 1: // Widgets
                // TODO: Implement widgets view
                break;
            }
          },
        ),
      ),
    );
  }
}
