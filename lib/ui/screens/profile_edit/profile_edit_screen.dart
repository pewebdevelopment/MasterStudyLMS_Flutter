import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/ui/bloc/edit_profile_bloc/bloc.dart';
import 'package:masterstudy_app/ui/bloc/profile/profile_bloc.dart';
import 'package:masterstudy_app/ui/bloc/profile/profile_event.dart';
import 'package:masterstudy_app/ui/screens/change_password/change_password_screen.dart';

import '../../../data/utils.dart';
import '../../widgets/dialog_author.dart';
import '../splash/splash_screen.dart';

class ProfileEditScreenArgs {
  final Account? account;
  final dynamic avatar_url;

  ProfileEditScreenArgs(this.account, this.avatar_url);
}

class ProfileEditScreen extends StatelessWidget {
  static const routeName = "profileEditScreen";
  ProfileEditScreenArgs? args;
  ProfileEditScreenArgs? avatar_url;
  final EditProfileBloc bloc;

  ProfileEditScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)?.settings.arguments as ProfileEditScreenArgs;
    avatar_url = ModalRoute.of(context)?.settings.arguments as ProfileEditScreenArgs;
    return BlocProvider(
      create: (context) => bloc..account = args!.account!,
      child: _ProfileEditWidget(avatar_url: avatar_url),
    );
  }
}

class _ProfileEditWidget extends StatefulWidget {
  final dynamic avatar_url;

  const _ProfileEditWidget({Key? key, this.avatar_url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEditWidgetState();
}

class _ProfileEditWidgetState extends State<_ProfileEditWidget> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode myFocusNode = new FocusNode();

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _facebookController = TextEditingController();
  TextEditingController _twitterController = TextEditingController();
  TextEditingController _instagramController = TextEditingController();

  var enableInputs = true;
  late bool demoEnableInputs;
  var passwordVisible = false;
  late EditProfileBloc _bloc;

  @override
  void initState() {
    _bloc = BlocProvider.of<EditProfileBloc>(context);
    passwordVisible = true;
    _firstNameController.text = _bloc.account.meta!.first_name;
    _lastNameController.text = _bloc.account.meta!.last_name;
    _emailController.text = _bloc.account.email;
    _bioController.text = _bloc.account.meta!.description;
    _occupationController.text = _bloc.account.meta!.position!;
    _facebookController.text = _bloc.account.meta!.facebook!;
    _twitterController.text = _bloc.account.meta!.twitter;
    _instagramController.text = _bloc.account.meta!.instagram;
    if(preferences.getBool('demo') == null) {
      demoEnableInputs = false;
    }else {
      demoEnableInputs = preferences.getBool('demo')!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          centerTitle: true,
          title: Text(
            localizations!.getLocalization("edit_profile_title"),
            textScaleFactor: 1.0,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: BlocListener(
          bloc: _bloc,
          listener: (context, state) {
            if (state is UpdateEditProfileState) {
              //SnackBar after edit profile
              BlocProvider.of<ProfileBloc>(context)..add(FetchProfileEvent());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  localizations!.getLocalization("profile_updated_message"),
                  textScaleFactor: 1.0,
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Ok',
                  onPressed: () {},
                ),
              ));
            }

            if (state is CloseEditProfileState) {
              //SnackBar after edit profile
              BlocProvider.of<ProfileBloc>(context)..add(FetchProfileEvent());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  localizations!.getLocalization("profile_change_canceled"),
                  textScaleFactor: 1.0,
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Ok',
                  onPressed: () {},
                ),
              ));
            }
          },
          child: BlocBuilder(
            bloc: _bloc,
            builder: (context, state) {
              return _buildBody(state, widget.avatar_url);
            },
          ),
        ));
  }

  final ImagePicker _picker = ImagePicker();
  File? _image;

  _buildBody(state, avatar_url) {
    enableInputs = !(state is LoadingEditProfileState);
    Widget image;
    String userRole = '';
    if(_bloc.account.roles.isEmpty) {
       userRole = 'subscriber';
    }else {
       userRole = _bloc.account.roles[0];
    }
    final Widget svg = SvgPicture.asset(
      "assets/icons/file_icon.svg",
      color: Colors.white,
    );

    ///Check avatar
    if (_image == null && avatar_url != null) {
      image = CachedNetworkImage(
        imageUrl: avatar_url.avatar_url.toString(),
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          return SizedBox(
            width: 100.0,
            child: Image.asset('assets/icons/logo.png'),
          );
        },
        width: 100.0,
      );
    } else if (_image != null) {
      image = Image.file(
        _image!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    } else {
      image = SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          "assets/icons/empty_user.svg",
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          //Image
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60.0),
                  child: image,
                ),
              ),
            ),
          ),
          //Button "Change Photo"
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    side: BorderSide(color: secondColor!),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(secondColor),
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8)),
              ),
              onPressed: () async {
                if(demoEnableInputs) {
                  showDialogError(context,'Demo Mode');
                }else {
                  XFile? image = await _picker.pickImage(source: ImageSource.gallery);

                  setState(() {
                    _image = File(image!.path);
                  });
                }
              },
              child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        child: svg,
                        width: 23,
                        height: 23,
                      ),
                      Text(
                        localizations!.getLocalization("change_photo_button"),
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          //FirstName
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _firstNameController,
              enabled: enableInputs,
              readOnly: demoEnableInputs,
              cursorColor: mainColor,
              decoration: InputDecoration(
                labelText: localizations!.getLocalization("first_name"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //LastName
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _lastNameController,
              enabled: enableInputs,
              readOnly: demoEnableInputs,
              cursorColor: mainColor,
              decoration: InputDecoration(
                labelText: localizations!.getLocalization("last_name"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //Occupation
          userRole != 'subscriber'
              ? Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                  child: TextFormField(
                    controller: _occupationController,
                    enabled: enableInputs,
                    readOnly: demoEnableInputs,
                    cursorColor: mainColor,
                    decoration: InputDecoration(
                      labelText: localizations!.getLocalization("occupation"),
                      filled: true,
                      labelStyle: TextStyle(
                        color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: mainColor!, width: 2),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          //Email
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _emailController,
              enabled: enableInputs,
              validator: _validateEmail,
              readOnly: demoEnableInputs,
              cursorColor: mainColor,
              decoration: InputDecoration(
                labelText: localizations!.getLocalization("email_label_text"),
                helperText: localizations!.getLocalization("email_helper_text"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //Password
          /* Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _passwordController,
              enabled: enableInputs,
              obscureText: passwordVisible,
              cursorColor: mainColor,
              decoration: InputDecoration(
                  labelText: localizations!.getLocalization("password_label_text"),
                  helperText: localizations!.getLocalization("password_registration_helper_text"),
                  filled: true,
                  labelStyle: TextStyle(
                    color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColor!, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    color: Theme.of(context).primaryColorDark,
                  )),
              validator: (value) {
                if (value == null) {
                  return null;
                } else {
                  if (value.length < 8) {
                    return localizations!.getLocalization("password_register_characters_count_error_text");
                  }
                }

                return null;
              },
            ),
          ),*/
          //Bio
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _bioController,
              enabled: enableInputs,
              maxLines: 5,
              readOnly: demoEnableInputs,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: mainColor,
              decoration: InputDecoration(
                labelText: localizations!.getLocalization("bio"),
                helperText: localizations!.getLocalization("bio_helper"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //Facebook
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _facebookController,
              enabled: enableInputs,
              readOnly: demoEnableInputs,
              cursorColor: mainColor,
              decoration: InputDecoration(
                labelText: 'Facebook',
                hintText: localizations!.getLocalization("enter_url"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //Twitter
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _twitterController,
              enabled: enableInputs,
              cursorColor: mainColor,
              readOnly: demoEnableInputs,
              decoration: InputDecoration(
                labelText: 'Twitter',
                hintText: localizations!.getLocalization("enter_url"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //Instagram
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: _instagramController,
              enabled: enableInputs,
              cursorColor: mainColor,
              readOnly: demoEnableInputs,
              decoration: InputDecoration(
                labelText: 'Instagram',
                hintText: localizations!.getLocalization("enter_url"),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!, width: 2),
                ),
              ),
            ),
          ),
          //Button Save
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: new MaterialButton(
              minWidth: double.infinity,
              color: mainColor,
              onPressed: () {
                if(demoEnableInputs) {
                  showDialogError(context,'Demo Mode');
                }else {
                  if (_formKey.currentState!.validate()) {
                    if (_image == null) {
                      _bloc.add(
                        SaveEvent(
                          _firstNameController.text,
                          _lastNameController.text,
                          _passwordController.text,
                          _bioController.text,
                          _occupationController.text,
                          _facebookController.text,
                          _twitterController.text,
                          _instagramController.text,
                        ),
                      );
                    } else {
                      _bloc.add(SaveEvent(
                        _firstNameController.text,
                        _lastNameController.text,
                        _passwordController.text,
                        _bioController.text,
                        _occupationController.text,
                        _facebookController.text,
                        _twitterController.text,
                        _instagramController.text,
                        _image,
                      ));
                    }
                  }
                }
              },
              child: setUpButtonChild(enableInputs),
              textColor: Colors.white,
            ),
          ),
          //Button Restore Password
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: new MaterialButton(
              minWidth: double.infinity,
              color: mainColor,
              onPressed: () {
                if(demoEnableInputs) {
                  showDialogError(context,'Demo Mode');
                }else {
                  Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
                }
              },
              child: Text(
                "CHANGE PASSWORD",
                textScaleFactor: 1.0,
              ),
              textColor: Colors.white,
            ),
          ),
          //Button Delete Account
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: new MaterialButton(
              minWidth: double.infinity,
              color: Colors.red.shade600,
              onPressed: () {
                if (demoEnableInputs) {
                  showDialogError(context, 'Demo Mode');
                } else {
                  showDeleteAccountDialog(context);
                  // Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
                }
              },
              child: Text(
                "DELETE ACCOUNT",
                textScaleFactor: 1.0,
              ),
              textColor: Colors.white,
            ),
          ),
          //Cancel
          Padding(
            padding: const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
            ),
            child: TextButton(
              child: Text(
                localizations!.getLocalization("cancel_button"),
                textScaleFactor: 1.0,
                style: TextStyle(color: mainColor),
              ),
              onPressed: () {
                _bloc.add(CloseScreenEvent());
              },
            ),
          )
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null) {
      // The form is empty
      return localizations!.getLocalization("email_empty_error_text");
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" + "\\@" + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" + "(" + "\\." + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return localizations!.getLocalization("email_invalid_error_text");
  }

  showDeleteAccountDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        localizations!.getLocalization("cancel_button"),
        textScaleFactor: 1.0,
        style: TextStyle(
          color: mainColor,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Delete",
        textScaleFactor: 1.0,
        style: TextStyle(color: mainColor),
      ),
      onPressed: () {
        preferences!.setBool('demo', false);
        BlocProvider.of<ProfileBloc>(context).add(LogoutProfileEvent());
        Navigator.of(context).pushNamedAndRemoveUntil(SplashScreen.routeName, (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Account", textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
      content: Text(
        "Do you really want to delete account?",
        textScaleFactor: 1.0,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

Widget setUpButtonChild(enable) {
  if (enable == true) {
    return new Text(
      localizations!.getLocalization("save_button"),
      textScaleFactor: 1.0,
    );
  } else {
    return SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }
}
