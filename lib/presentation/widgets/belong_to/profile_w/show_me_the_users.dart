import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/data/models/user_personal_info.dart';
import 'package:instagram/core/functions/toast_show.dart';
import 'package:instagram/presentation/cubit/firestoreUserInfoCubit/user_info_cubit.dart';
import '../../../cubit/follow/follow_cubit.dart';
import '../../global/circle_avatar_image/circle_avatar_of_profile_image.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/presentation/widgets/belong_to/profile_w/which_profile_page.dart';

class ShowMeTheUsers extends StatefulWidget {
  final List<UserPersonalInfo> usersInfo;
  final bool isThatFollower;
  final ValueNotifier<UserPersonalInfo>? userInfo;
  final bool showSearchBar;
  final bool showColorfulCircle;

  const ShowMeTheUsers({
    Key? key,
    required this.usersInfo,
    this.showColorfulCircle = true,
    this.isThatFollower = true,
    this.showSearchBar = true,
    this.userInfo,
  }) : super(key: key);

  @override
  State<ShowMeTheUsers> createState() => _ShowMeTheUsersState();
}

class _ShowMeTheUsersState extends State<ShowMeTheUsers> {
  late UserPersonalInfo myPersonalInfo;
  @override
  initState() {
    myPersonalInfo = FirestoreUserInfoCubit.getMyPersonalInfo(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.usersInfo.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.separated(
            shrinkWrap: true,
            primary: false,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            itemBuilder: (context, index) {
              return containerOfUserInfo(
                  widget.usersInfo[index], widget.isThatFollower);
            },
          separatorBuilder: (context,index)=>const SizedBox(height: 10),
            itemCount: widget.usersInfo.length,),
      );
    } else {
      return Center(
        child: Text(
          widget.isThatFollower
              ? StringsManager.noFollowers.tr()
              : StringsManager.noFollowings.tr(),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
  }

  Widget containerOfUserInfo(UserPersonalInfo userInfo, bool isThatFollower) {
    String hash = "${userInfo.userId.hashCode}userInfo";
    return InkWell(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WhichProfilePage(
              userId: userInfo.userId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.only( start: 10, top: 10),
        child: Row(children: [
          Hero(
            tag: hash,
            child: CircleAvatarOfProfileImage(
              bodyHeight: 600,
              hashTag: hash,
              userInfo: userInfo,
              showColorfulCircle:widget.showColorfulCircle ,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo.userName,
                  style: Theme.of(context).textTheme.headline2,
                ),
                const SizedBox(height: 5),
                Text(
                  userInfo.name,
                  style: Theme.of(context).textTheme.headline1,
                )
              ],
            ),
          ),
          followButton(userInfo, isThatFollower),
        ]),
      ),
    );
  }

  Widget followButton(UserPersonalInfo userInfo, bool isThatFollower) {
    return BlocBuilder<FollowCubit, FollowState>(
      builder: (followContext, stateOfFollow) {
        return Expanded(
          child: Builder(builder: (userContext) {
            if (myPersonalId == userInfo.userId) {
              return Container();
            } else {
              return GestureDetector(
                  onTap: () async {
                    if (myPersonalInfo.followedPeople
                        .contains(userInfo.userId)) {
                      BlocProvider.of<FollowCubit>(followContext)
                          .removeThisFollower(
                              followingUserId: userInfo.userId,
                              myPersonalId: myPersonalId);
                      myPersonalInfo.followedPeople.remove(userInfo.userId);
                    } else {
                      BlocProvider.of<FollowCubit>(followContext)
                          .followThisUser(
                              followingUserId: userInfo.userId,
                              myPersonalId: myPersonalId);
                      myPersonalInfo.followedPeople.add(userInfo.userId);
                    }
                  },
                  child: whichContainerOfText(stateOfFollow, userInfo));
            }
          }),
        );
      },
    );
  }

  Widget whichContainerOfText(
      FollowState stateOfFollow, UserPersonalInfo userInfo) {
    if (stateOfFollow is CubitFollowThisUserFailed) {
      ToastShow.toastStateError(stateOfFollow);
    }

    return !myPersonalInfo.followedPeople.contains(userInfo.userId)
        ? containerOfFollowText(
            text: StringsManager.follow.tr(),
            isThatFollower: false,
          )
        : containerOfFollowText(
            text: StringsManager.following.tr(),
            isThatFollower: true,
          );
  }

  Widget containerOfFollowText(
      {required String text, required bool isThatFollower}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 45,end: 15),
      child: Container(
        height: 32.0,
        decoration: BoxDecoration(
          color:
              isThatFollower ? Theme.of(context).primaryColor : ColorManager.blue,
          border: Border.all(
              color: Theme.of(context).bottomAppBarColor,
              width: isThatFollower ? 1.0 : 0),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 17.0,
                color: isThatFollower
                    ? Theme.of(context).focusColor
                    : ColorManager.white,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
