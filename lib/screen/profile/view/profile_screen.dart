import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/chat/controller/chat_unread_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_rooms_screen.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/earnings/view/earnings_screen.dart';
import 'package:alo_ride_driver_app/screen/profile/controller/profile_controller.dart';
import 'package:alo_ride_driver_app/screen/profile/view/common_profile_data.dart';
import 'package:alo_ride_driver_app/screen/payout/view/weekly_payout_screen.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   ProfileController profileController = Get.put(ProfileController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppAppBar(
//         backgroundColor: Colors.transparent,
//         leading: Icon(Icons.menu),
//         title: "Profile",
//         actions: [
//           InkWell(  onTap: () async {
//             if (!profileController.isSave.value) {
//               // ENTER EDIT MODE
//               profileController.isSave.value = true;
//
//             } else {
//               profileController.isSave.value = false;
//             }
//           },child: AppText(text: "Edit", fontSize: 16),),
//           Gap(16),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               height: 2,
//               color: AppColors.darkTextColor,
//             ),
//             Gap(10),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Gap(20),
//                   Row(
//                     children: [
//                       Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 45.r,
//                             backgroundImage: const NetworkImage(
//                               "https://i.pravatar.cc/300",
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               padding: EdgeInsets.all(6.w),
//                               decoration: const BoxDecoration(
//                                 color: AppColors.secondary,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.edit,
//                                 size: 14,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Gap(30.h),
//                       AppText(
//                         text: "Jackson",
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.borderColor,
//                       ),
//                     ],
//                   ),
//                   Gap(50.h),
//                   CommonProfileData(
//                     icon: AppImages.userIcon,
//                     title: "Name",
//                     isSave: profileController.isSave,
//                     controller: profileController.nameController,
//                     subTitle: 'Jackson',
//                   ),
//                   Divider(
//                     color: Color(0xffD9D9D9)
//                   ).paddingSymmetric(vertical: 10),
//                   CommonProfileData(
//                     icon: AppImages.mailIcon,
//                     title: "Email",
//                     isSave: profileController.isSave,
//                     readOnly: true,
//                     controller: profileController.emailController,
//                     subTitle: "jackson.123@email.com",
//                   ),
//                   Divider(
//                     color: Color(0xffD9D9D9)
//                   ).paddingSymmetric(vertical: 10),
//                   CommonProfileData(
//                     icon: AppImages.phoneIcon,
//                     title: "Phone Number",
//                     isMobile: true,
//                     readOnly: true,
//                     keyboardType: TextInputType.number,
//                     controller: profileController.phoneNumberController,
//                     isSave: profileController.isSave,
//
//                     subTitle: "+1 985 547 2222",
//                   ),
//                   Gap(50),
//                   Divider(color: Color(0xffD9D9D9)),
//                   Gap(10),
//                   Row(
//                     children: [
//                       AppImage(image: AppImages.logoutIcon,imageType: ImageType.svgAsset,),
//                       Gap(28),
//                       AppText(
//                         text: "Logout",
//                         color: AppColors.darkGrayColor,
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: AppButton(text: "Save", onTap: () {
//
//         },),
//       ),
//     );
//   }
//
//   Widget profileTile(
//     IconData icon,
//     String label,
//     String value, {
//     bool isCopy = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: Get.height * 0.03, color: AppColors.borderColor),
//             const SizedBox(width: 10),
//             AppText(
//               text: label,
//               color: AppColors.darkGrayColor,
//               fontWeight: FontWeight.w400,
//             ),
//             Spacer(),
//             if (isCopy == true)
//               IconButton(
//                 onPressed: () {
//                   Clipboard.setData(ClipboardData(text: value));
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("$label code copy successfully")),
//                   );
//                 },
//                 icon: Icon(Icons.copy),
//               ),
//           ],
//         ),
//         const SizedBox(height: 5),
//         Padding(
//           padding: const EdgeInsets.only(left: 30.0),
//           child: AppText(
//             text: value,
//             color: AppColors.black,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const Divider(height: 30),
//       ],
//     );
//   }
// }




class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());
  // @override
  // void initState() {
  //   profileController.getProfile();
  //   super.initState();
  // }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await profileController.getProfile();
      profileController.isSave.value = false; // Show "Edit" initially
    });
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to permanently delete your account?",
          ),
          actions: [

            /// ❌ CANCEL
            AppButton(
              text: "Cancel",
              onTap: () {
                Get.back();
              },
            ),

            /// ✅ SPACE FIXED
            const SizedBox(height: 10),

            /// ❌ DELETE
            Obx(() {
              return AppButton(
                isLoading: profileController.isDeleteLoading.value,
                text: "Delete",
                onTap: () {
                  Get.back();
                  profileController.deleteAccount();
                  authController.logout();
                },
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.to(()=>DashboardScreen()); // ✅ CLOSE APP
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(
          backgroundColor: Colors.transparent,
          leading: SizedBox(),
          showBack: false,
          leadingWidth: 0,
          title: "Profile",
          // actions: [
          //   InkWell(
          //     onTap: () async {
          //       profileController.isSave.value = true;
          //       // if (!profileController.isSave.value) {
          //       //   // ENTER EDIT MODE
          //       //   profileController.isSave.value = true;
          //       // } else {
          //       //   profileController.isSave.value = false;
          //       // }
          //     },
          //     child: Obx(() {
          //       return AppText(
          //         text: profileController.isSave.value == true ? "Save" : "Edit",
          //         fontSize: 16,
          //       );
          //     }),
          //   ),
          //   Gap(16),
          // ],
        ),
        body: Obx(() {
          return profileController.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 2,
                  color: AppColors.darkTextColor,
                ),
                Gap(10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(20),
                      // Row(
                      //   children: [
                      //     Stack(
                      //       children: [
                      //         CircleAvatar(
                      //           radius: 45.r,
                      //           backgroundImage: const NetworkImage(
                      //             "https://i.pravatar.cc/300",
                      //           ),
                      //         ),
                      //         Positioned(
                      //           bottom: 0,
                      //           right: 0,
                      //           child: Container(
                      //             padding: EdgeInsets.all(6.w),
                      //             decoration: const BoxDecoration(
                      //               color: AppColors.secondary,
                      //               shape: BoxShape.circle,
                      //             ),
                      //             child: const Icon(
                      //               Icons.edit,
                      //               size: 14,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     Gap(30.h),
                      //     AppText(
                      //       text: "Jackson",
                      //       fontSize: 18,
                      //       fontWeight: FontWeight.w500,
                      //       color: AppColors.borderColor,
                      //     ),
                      //   ],
                      // ),
                      Row(
                        children: [
                          Obx(() {
                            Widget avatarWidget;

                            // 1️⃣ PICKED IMAGE (FILE)
                            if (profileController.profileImageFile.value != null) {
                              avatarWidget = ClipOval(
                                child: Image.file(
                                  profileController.profileImageFile.value!,
                                  width: 90.w,
                                  height: 90.w,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }

                            // 2️⃣ NETWORK IMAGE (API)
                            else if (profileController.profileImageUrl.isNotEmpty) {
                              avatarWidget = ClipOval(
                                child: Image.network(
                                  profileController.profileImageUrl.value,
                                  width: 90.w,
                                  height: 90.w,
                                  fit: BoxFit.cover,

                                  /// 🔄 LOADER
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: 90.w,
                                      height: 90.w,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },

                                  /// ❌ ERROR IMAGE
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                      "https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png",
                                      width: 90.w,
                                      height: 90.w,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              );
                            }

                            // 3️⃣ DEFAULT AVATAR
                            else {
                              avatarWidget = ClipOval(
                                child: Image.network(
                                  "https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png",
                                  width: 90.w,
                                  height: 90.w,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }

                            return Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: avatarWidget,
                                ),

                                /// ✏️ EDIT ICON
                                if (profileController.isSave.value)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: profileController.showImagePicker,
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),

                          Gap(30.h),

                          AppText(
                            text: profileController.nameController.text.isNotEmpty
                                ? profileController.nameController.text
                                : "",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.borderColor,
                          ),
                        ],
                      ),

                      Gap(50.h),
                      CommonProfileData(
                        icon: AppImages.userIcon,
                        title: "Name",
                        isSave: profileController.isSave,
                        controller: profileController.nameController,
                        subTitle: profileController.nameController.text,
                      ),
                      Divider(
                        color: Color(0xffD9D9D9),
                      ).paddingSymmetric(vertical: 10),
                      CommonProfileData(
                        icon: AppImages.mailIcon,
                        title: "Email",
                        isSave: profileController.isSave,
                        readOnly: true,
                        controller: profileController.emailController,
                        subTitle: profileController.emailController.text,
                      ),
                      Divider(
                        color: Color(0xffD9D9D9),
                      ).paddingSymmetric(vertical: 10),
                      CommonProfileData(
                        icon: AppImages.phoneIcon,
                        title: "Phone Number",
                        isMobile: true,
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        controller: profileController.phoneNumberController,
                        isSave: profileController.isSave,
                        subTitle:
                        profileController.phoneNumberController.text,
                      ),
                      Gap(50),
                      Divider(color: Color(0xffD9D9D9)),
                      Gap(10),

                      /// 💬 MESSAGES
                      InkWell(
                        onTap: () => Get.to(() => const ChatRoomsScreen()),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.secondary,
                              size: 24,
                            ),
                            Gap(24),
                            AppText(
                              text: "Messages",
                              color: AppColors.darkGrayColor,
                            ),
                            const Spacer(),
                            Obx(() {
                              final unread =
                                  ChatUnreadController.instance.total;
                              if (unread == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: UnreadDot(count: unread),
                              );
                            }),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.lightGrayText,
                            ),
                          ],
                        ),
                      ),
                      Gap(10),
                      Divider(color: Color(0xffD9D9D9)),
                      Gap(10),

                      /// 💵 EARNINGS
                      InkWell(
                        onTap: () => Get.to(() => const EarningsScreen()),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: AppColors.secondary,
                              size: 24,
                            ),
                            Gap(24),
                            AppText(
                              text: "Earnings",
                              color: AppColors.darkGrayColor,
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.lightGrayText,
                            ),
                          ],
                        ),
                      ),
                      Gap(10),
                      Divider(color: Color(0xffD9D9D9)),
                      Gap(10),

                      /// 💰 WEEKLY PAYOUT
                      InkWell(
                        onTap: () => Get.to(() => const WeeklyPayoutScreen()),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.secondary,
                              size: 24,
                            ),
                            Gap(24),
                            AppText(
                              text: "Weekly Payout",
                              color: AppColors.darkGrayColor,
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.lightGrayText,
                            ),
                          ],
                        ),
                      ),
                      Gap(10),
                      Divider(color: Color(0xffD9D9D9)),
                      Gap(10),

                      Row(
                        children: [
                          AppImage(
                            image: AppImages.logoutIcon,
                            imageType: ImageType.svgAsset,
                          ),
                          Gap(28),
                          Obx(() {
                            return profileController.isLogoutUser.value
                                ? CircularProgressIndicator()
                                : InkWell(
                              onTap: () {
                                profileController.logoutUser();
                                authController.logout();
                              },
                              child: AppText(
                                text: "Logout",
                                color: AppColors.darkGrayColor,
                              ),
                            );
                          }),

                        ],
                      ),
                      Gap(30),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Obx(() {
        //     return AppButton(
        //       isLoading: profileController.isEditProfile.value,
        //       // text: profileController.isSave.value == true?"Save":"Edit",
        //       text: profileController.isSave.value == true ? "Save" : "Edit",
        //       onTap: () {
        //         if (profileController.isSave.value) {
        //           // 👉 SAVE MODE
        //           profileController.editProfile();
        //         } else {
        //           // 👉 SWITCH TO SAVE MODE
        //           profileController.isSave.value = true;
        //         }
        //       },
        //
        //       // onTap: () {
        //       //   profileController.isSave.value = true;
        //       //   if(profileController.isSave.value == true){
        //       //     profileController.editProfile();
        //       //   }
        //       //
        //       // },
        //     );
        //   },),
        // ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 💾 SAVE BUTTON
                AppButton(
                  isLoading: profileController.isEditProfile.value,
                  // text: "Save",
                  text: profileController.isSave.value ? "Update" : "Edit",
                  onTap: () {
                    if (profileController.isSave.value) {
                      profileController.editProfile();
                    } else {
                      profileController.isSave.value = true;
                    }
                  },
                ),

                const SizedBox(height: 12),

                /// ❌ DELETE BUTTON
                AppButton(
                  isLoading: profileController.isDeleteLoading.value,
                  text: "Delete Account",
                  onTap: showDeleteDialog,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
