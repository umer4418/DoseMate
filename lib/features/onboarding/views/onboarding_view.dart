import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: ResponsiveScaffoldBody(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: Responsive.pagePadding(context),
                  ),
                  child: TextButton(
                    onPressed: controller.finish,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.pages.length,

                  onPageChanged: controller.onPageChanged,

                  itemBuilder: (
                      BuildContext context,
                      int index,
                      ) {
                    final page = controller.pages[index];

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                        Responsive.pagePadding(context),
                      ),

                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(28),

                              child: Image.asset(
                                page['image']!,
                                width: double.infinity,
                                fit: BoxFit.cover,

                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius:
                                      BorderRadius.circular(28),
                                    ),

                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                          Text(
                            page['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 14),
                          Text(
                            page['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.secondaryText,
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Obx(
                    () {
                  return Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: List.generate(
                      controller.pages.length,
                          (index) {
                        final bool active =
                            controller.index.value == index;

                        return AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 250),

                          margin:
                          const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),

                          width: active ? 26 : 8,
                          height: 8,

                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : Colors.black26,

                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context),
                  0,
                  Responsive.pagePadding(context),
                  24,
                ),

                child: Obx(
                      () {
                    final bool last =
                        controller.index.value ==
                            controller.pages.length - 1;

                    return SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: ElevatedButton(
                        onPressed: controller.next,

                        child: Text(
                          last
                              ? 'Get Started'
                              : 'Next',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}