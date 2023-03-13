import 'dart:async';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '/base/system_param.dart';
import '/helper/helper.dart';
import '/helper/rest_service.dart';
import '/model/personal_info_model.dart';
import '/model/personal_training_model.dart';
import '/model/user_model.dart';
import '/pages/profile/skill/profile_skill.dart';
import '/routerName.dart';
import '/widget/reuseable_widget.dart';

class ProfileSkillTrainingEdit extends StatefulWidget {
  final User user;
  final PersonalInfoProfilData profileInfo;
  // final PersonalEducation educationData;
  final int trainingId;

  const ProfileSkillTrainingEdit(
      {Key? key,
      required this.user,
      required this.profileInfo,
      required this.trainingId})
      : super(key: key);

  @override
  _ProfileSkillTrainingEditState createState() =>
      _ProfileSkillTrainingEditState();
}

class _ProfileSkillTrainingEditState
    extends State<ProfileSkillTrainingEdit> {
  
  final _keyForm = GlobalKey<FormState>();
  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');
  TextEditingController _institutionCtrl = new TextEditingController();
  TextEditingController _trainingNameCtrl = new TextEditingController();

  String _mulaiValueStr = "";
  String _akhirValueStr = "";

  dynamic _mulaiValue;
  dynamic _akhirValue;
  Timer? timer;
  int count = 0;
  
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      int? limit = widget.user.timeoutLogin * 60;
      print('ini limit time logout nhya');
      print(limit);
      if (count < limit) {
        print(count);
        setState(() {
          count++;
        });
      } else {
        timer.cancel();
        Helper.updateIsLogin(widget.user, 0);
        Navigator.of(context).pushNamedAndRemoveUntil(
            loginScreen, (Route<dynamic> route) => false);
      }
    });
    if (widget.trainingId != 0) {
      getTraining();
    }
    
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
      },
      child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSkill(
                    user: widget.user,
                    profileInfo: widget.profileInfo, /*timer: timer!,*/
                  ),
                ));
            return false;
          },
          child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('Training Add/ Edit'),
                centerTitle: true,
                backgroundColor: SystemParam.colorCustom,
                automaticallyImplyLeading: false
                // leading: IconButton(
                //   icon: Icon(Icons.arrow_back, color: Colors.black),
                //   //onPressed: () => Navigator.of(context).pop(),
                //   onPressed: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //       builder: (context) => ProfileSkill(
                //     //         user: widget.user,
                //     //         profileInfo: widget.profileInfo,
                //     //       ),
                //     //     ));
                //   },
                // ),
              ),
              body: loading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Form(
                      key: _keyForm,
                      // autovalidateMode: ,
                      // autovalidate: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Nama Institusi',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _institutionCtrl,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Nama Training',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _trainingNameCtrl,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Tanggal mulai',
                                  style:Reuseable.titleStyle),
                              TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        widget.trainingId==0?
                         DateTimeField(
                          //initialValue: _mulaiValue ?? DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return "this field is required";
                            }
                            return null;
                          },
                          onSaved: (valueDate) {
                            _mulaiValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          onChanged: (valueDate) {
                            _mulaiValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          format: SystemParam.formatDateDisplay,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                locale: Locale('id'),
                                firstDate: DateTime(SystemParam.firstDate),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(SystemParam.lastDate),
                                fieldHintText: SystemParam.strFormatDateHint);
                          },
                          decoration: Reuseable.inputDecorationDate
                        )
                        : DateTimeField(
                          initialValue: _mulaiValue ?? DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return "this field is required";
                            }
                            return null;
                          },
                          onSaved: (valueDate) {
                            _mulaiValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          onChanged: (valueDate) {
                            _mulaiValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          format: SystemParam.formatDateDisplay,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                locale: Locale('id'),
                                firstDate: DateTime(SystemParam.firstDate),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(SystemParam.lastDate),
                                fieldHintText: SystemParam.strFormatDateHint);
                          },
                          decoration: Reuseable.inputDecorationDate
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Tanggal Akhir',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        widget.trainingId == 0 ?
                        DateTimeField(
                          //initialValue: _akhirValue ?? DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return "this field is required";
                            }
                            return null;
                          },
                          onSaved: (valueDate) {
                            _akhirValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          onChanged: (valueDate) {
                            _akhirValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          format: SystemParam.formatDateDisplay,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                locale: Locale('id'),
                                firstDate: DateTime(SystemParam.firstDate),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(SystemParam.lastDate),
                                fieldHintText: SystemParam.strFormatDateHint);
                          },
                          decoration: Reuseable.inputDecorationDate
                        )
                        :DateTimeField(
                          initialValue: _akhirValue ?? DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return "this field is required";
                            }
                            return null;
                          },
                          onSaved: (valueDate) {
                            _akhirValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          onChanged: (valueDate) {
                            _akhirValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          format: SystemParam.formatDateDisplay,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                locale: Locale('id'),
                                firstDate: DateTime(SystemParam.firstDate),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(SystemParam.lastDate),
                                fieldHintText: SystemParam.strFormatDateHint);
                          },
                          decoration: Reuseable.inputDecorationDate
                        ),
                        Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                primary: SystemParam.colorCustom),
                            child: Text("SIMPAN"),
                            onPressed: () {
                              if (_keyForm.currentState!.validate()) {
                                saveData();
                              }
                            },
                          ),
                        )
                          ],
                        ),
                      )))),
    );
  }

  void getTraining() async {

    loading = true;
    var data = {
      "id": widget.trainingId,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalTrainingById, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      PersonalTrainingModel model =
          personalTrainingModelFromJson(response.body.toString());

      if (model.data.length > 0) {
        PersonalTraining we = model.data[0];
        _institutionCtrl.text = we.institutionName;
        _trainingNameCtrl.text = we.trainingName;
        if (we.trainingDateStart != null) {
          _mulaiValue = we.trainingDateStart;
          _mulaiValueStr =
              SystemParam.formatDateValue.format(we.trainingDateStart);
        }
        if (we.trainingDateEnd != null) {
          _akhirValue = we.trainingDateEnd;
          _akhirValueStr =
              SystemParam.formatDateValue.format(we.trainingDateEnd);
        }
      }

      loading = false;
    });
  }


  void saveData() async {
    var data = {
      "id": widget.trainingId,
      "created_by": widget.user.id,
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId,
      "institution_name":_institutionCtrl.text,
      "training_name":_trainingNameCtrl.text,
      "training_date_stat": _mulaiValueStr,
      "training_date_end": _akhirValueStr
    };
  
    String function = SystemParam.fPersonalTrainingCreate;
    if(widget.trainingId!=0){
      function = SystemParam.fPersonalTrainingUpdate;
    }

    var response = await RestService() .restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    print(status);

    if (code == "0") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileSkill(
                    user: widget.user,
                    profileInfo: widget.profileInfo, /*timer: timer!,*/
                  )));
    } else {
      Fluttertoast.showToast(
          msg: status,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
