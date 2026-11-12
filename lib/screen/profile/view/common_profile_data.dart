import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/common/app_textfield.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CommonProfileData extends StatelessWidget {
  final String icon;
  final String title;
  final String subTitle;
  final RxBool? isSave;
  final TextEditingController? controller;
  final void Function()? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final bool? isMobile;
  final bool showCopyShare;
  final double? height;
  final double? width;
  final BoxFit fit;
  const CommonProfileData({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.isSave,
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.isMobile,
    this.showCopyShare = false, this.height, this.width,  this.fit = BoxFit.contain,
  });





  @override
  Widget build(BuildContext context) {
    controller?.text = subTitle;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon,color: AppColors.secondary,height: height,width: width,fit: fit,).paddingOnly(right: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                color: AppColors.borderColor,
              ),
              Obx(
                () =>
                    isSave?.value ?? false
                        ? AppTextField(
                          keyboardType: keyboardType,
                          isMobile: isMobile,
                          onTap: onTap,
                          hintText: subTitle,
                          fillColor: AppColors.white,
                          controller: controller,
                          isSave: isSave,
                          readOnly: readOnly,
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: AppText(
                                text: subTitle,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                                color: AppColors.darkGrayColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                // : AppText(
                //   text: subTitle,
                //   textStyle: size14TextStyle(),
                //   overflow: TextOverflow.visible,
                //   softWrap: true,
                // ),
              ),
            ],
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 8);
  }
}
