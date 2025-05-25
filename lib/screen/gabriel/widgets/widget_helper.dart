import '../core/app_export.dart';

class WidgetHelper {
  static Widget cardWidget(String title, String storeName, String subtitle,
      {String description = "", Color? color}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10.h),
        decoration: BoxDecoration(
          color: color ?? Colors.blue[50],
          borderRadius: BorderRadius.all(Radius.circular(15.adaptSize)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Text(
                  title,
                  style: title.length < 15
                      ? CustomTextStyle.titleMediumBluegray900
                      : CustomTextStyle.titleSmallBluegray900,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Divider(
                  color: appTheme.blueGray800,
                  thickness: 1.h,
                  height: 1.h,
                  indent: 10.v,
                  endIndent: 10.v,
                ),
              ]),
              SizedBox(height: 15.h),
              Text(
                storeName,
                style: CustomTextStyle.titleSmallBlack900,
              ),
              SizedBox(
                height: 10.h,
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "$subtitle\n ${description.isNotEmpty ? description : ""}",
                    style: description.isEmpty
                        ? CustomTextStyle.bodyMediumBlueGray600
                        : CustomTextStyle.bodySmallBlueGray600,
                    textAlign: TextAlign.end,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget appbarWidget(Function function, Widget title,
      {List<Widget>? actions}) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            function();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: appTheme.blueGray800),
        ),
        title: title,
        actions: actions ?? []);
  }
}
