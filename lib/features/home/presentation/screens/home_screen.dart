import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/core/routes/app_routes.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_bloc.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_state.dart';
import 'package:project_app/features/home/presentation/widgets/countdown_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CountdownBloc()..add(LoadCountdownEvents()),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi Taimoor 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Track your special moments',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
          ],
        ),
        body: BlocBuilder<CountdownBloc, CountdownState>(
          builder: (context, state) {
            if (state is CountdownLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is CountdownLoaded) {
              if (state.events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64.h,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No events added yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap + to add your first countdown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return CountdownCard(
                    event: event,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.eventDetail,
                        arguments: event,
                      ).then((_) {
                        // Refresh the events list when returning from detail screen
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
                  );
                },
              );
            }

            if (state is CountdownError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.h,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.addEvent,
            ).then((_) {
              // Refresh the events list when returning from add event screen
              context.read<CountdownBloc>().add(LoadCountdownEvents());
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
