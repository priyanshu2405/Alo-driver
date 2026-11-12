import 'package:alo_ride_driver_app/res/constant/app_colors.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Color? color;
  final int? maxLine;
  final Widget? prefixText;
  final Widget? suffixIcon;
  final bool? filled;
  final bool? obSecure;
  final Color? textColor;
  final bool? isMobile;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Color? fillColor;
  final String? Function(String?)? validator;
  final void Function(String)? onChange;
  final void Function()? onTap;
  final String? textFieldTitle;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final RxBool? isSave;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.color,
    this.maxLine,
    this.textColor,
    this.errorText,
    this.validator,
    this.isMobile,
    this.prefixText,
    this.onChange,
    this.keyboardType,
    this.filled,
    this.obSecure ,
    this.fillColor,
    this.enabled = true,
    this.readOnly = false,
    this.textFieldTitle,
    this.suffixIcon,
    this.inputFormatters,
    this.isSave, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isSave == true ? 20 : null,
            child: TextFormField(
              onChanged: onChange,
              textInputAction: TextInputAction.done,

              onTap: onTap,
              obscureText: obSecure ?? false,
              controller: controller,
              maxLines: maxLine ?? 1,
              readOnly: readOnly,
              inputFormatters:
                  inputFormatters ??
                  (isMobile ?? false
                      ? [LengthLimitingTextInputFormatter(10)]
                      : []),
              keyboardType: keyboardType,
              cursorColor: AppColors.black,
              style: TextStyle(color: AppColors.black,),
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                hintText: hintText,
                prefixIcon: prefixText,
                filled: filled,
                fillColor: fillColor,
                enabled: enabled,
                hintStyle: TextStyle(color: AppColors.black,),
                border:
                    isSave == true
                        ? UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        )
                        : filled == true
                        ? buildNoColorOutlineInputBorder()
                        : buildOutlineInputBorder(),
                enabledBorder:
                    isSave == true
                        ? UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        )
                        : filled == true
                        ? buildNoColorOutlineInputBorder()
                        : buildOutlineInputBorder(),
                focusedBorder:
                    isSave == true
                        ? UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        )
                        : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: AppColors.black,
                          ),
                        ),
                // focusedBorder:filled == true?buildNoColorOutlineInputBorder(): buildOutlineInputBorder(color: color),
                // enabledBorder:filled == true?buildNoColorOutlineInputBorder(): buildOutlineInputBorder(),
                // errorBorder: filled == true?buildNoColorOutlineInputBorder():buildOutlineInputBorder(),
                // focusedErrorBorder:filled == true?buildNoColorOutlineInputBorder(): buildOutlineInputBorder()
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder buildOutlineInputBorder({Color? color}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color ?? AppColors.black),
      borderRadius: BorderRadius.circular(6),
    );
  }

  OutlineInputBorder buildNoColorOutlineInputBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(6),
    );
  }
}



