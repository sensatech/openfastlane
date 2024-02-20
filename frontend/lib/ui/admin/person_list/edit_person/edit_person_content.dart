import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/person_list/person_view/validators.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/spacer.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class EditPersonContent extends StatefulWidget {
  const EditPersonContent({super.key, required this.person});

  final Person person;

  @override
  State<EditPersonContent> createState() => _EditPersonContentState();
}

class _EditPersonContentState extends State<EditPersonContent> {
  final GlobalKey<FormState> _key = GlobalKey();
  bool _autoValidate = false;

  // person data states
  late Gender? _gender;
  late bool? _dataProcessingAgreement;
  late String _email;
  late String _mobileNumber;

  @override
  void initState() {
    _gender = widget.person.gender;
    _dataProcessingAgreement = false;
    _email = '';
    _mobileNumber = '';

    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    Widget verticalSpace = mediumVerticalSpacer();
    Widget horizontalSpace = mediumHorizontalSpacer();

    double smallFormFieldWidth = 200;
    double mediumFormFieldWidth = 300;
    double largeFormFieldWidth = 400;
    return Form(
      key: _key,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: SizedBox(
        width: smallContentWidth,
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              children: [
                Text(lang.edit_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            largeVerticalSpacer(),
            horizontalPersonField(
              context,
              lang.gender,
              salutationRadioGroup(),
            ),
            verticalSpace,
            Row(
              children: [
                Expanded(
                  child: verticalPersonField(
                      context,
                      lang.firstname,
                      personTextFormField(context, widget.person.firstName, 'Text eingeben', mediumFormFieldWidth,
                          validator: validateName),
                      isRequired: true),
                ),
                horizontalSpace,
                Expanded(
                  child: verticalPersonField(
                      context,
                      lang.lastname,
                      personTextFormField(context, widget.person.lastName, 'Text eingeben', mediumFormFieldWidth,
                          validator: validateName),
                      isRequired: true),
                ),
                horizontalSpace,
                Expanded(
                  child: verticalPersonField(
                      context,
                      lang.birthdate,
                      personTextFormField(context, getFormattedDate(context, widget.person.dateOfBirth),
                          'Format: 10.05.1960', mediumFormFieldWidth,
                          validator: validateDate),
                      isRequired: true),
                ),
              ],
            ),
            verticalSpace,
            Row(
              children: [
                Expanded(
                  child: verticalPersonField(
                      context,
                      lang.street_housenumber,
                      personTextFormField(
                          context, widget.person.address?.streetNameNumber, 'Text eingeben', largeFormFieldWidth,
                          validator: validateName),
                      isRequired: true),
                ),
                horizontalSpace,
                Expanded(
                  child: verticalPersonField(
                      context,
                      lang.stairs_door,
                      personTextFormField(
                          context, widget.person.address?.addressSuffix, 'z.B. 2/17', smallFormFieldWidth,
                          validator: validateName),
                      isRequired: true),
                ),
                horizontalSpace,
                Expanded(
                  child: verticalPersonField(
                      context,
                      lang.zip,
                      personTextFormField(
                          context, widget.person.address?.postalCode, 'Zahl eingeben', smallFormFieldWidth,
                          validator: validateName),
                      isRequired: true),
                ),
              ],
            ),
            verticalSpace,
            const Divider(),
            verticalSpace,
            FormField<ContactDetails>(
                validator: validateEmailAndPhoneNumber,
                builder: (FormFieldState<ContactDetails> state) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('*E-Mail oder Mobilnummer anlegen, mindestens ein Feld muss ausgefüllt sein',
                            style: textTheme.bodyMedium),
                      ),
                      verticalSpace,
                      Row(
                        children: [
                          Expanded(
                            child: verticalPersonField(
                              context,
                              lang.email_address,
                              TextField(
                                onChanged: (value) {
                                  _email = value;
                                  state.didChange(ContactDetails(email: _email, mobileNumber: _mobileNumber));
                                },
                                decoration: InputDecoration(
                                    hintText: lang.email_address,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(smallSpace))),
                              ),
                            ),
                          ),
                          Expanded(
                            child: verticalPersonField(
                              context,
                              lang.mobile_number,
                              TextField(
                                onChanged: (value) {
                                  _mobileNumber = value;
                                  state.didChange(ContactDetails(email: _email, mobileNumber: _mobileNumber));
                                },
                                decoration: InputDecoration(
                                    hintText: lang.mobile_number,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(smallSpace))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      smallVerticalSpacer(),
                      if (state.hasError)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            state.errorText!,
                            style: textTheme.bodySmall!.copyWith(color: themeData.colorScheme.error),
                          ),
                        )
                    ],
                  );
                }),
            verticalSpace,
            Align(
              alignment: Alignment.centerLeft,
              child: FormField<bool>(
                initialValue: _dataProcessingAgreement,
                builder: (FormFieldState<bool> state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      horizontalPersonField(
                        context,
                        'Zustimmung zur Datenverarbeitung',
                        Row(
                          children: [
                            Checkbox(
                                value: _dataProcessingAgreement,
                                onChanged: (value) {
                                  setState(() {
                                    _dataProcessingAgreement = value;
                                    state.didChange(_dataProcessingAgreement);
                                  });
                                }),
                            smallHorizontalSpacer(),
                            const Text('Ja')
                          ],
                        ),
                        isRequired: true,
                      ),
                      if (state.hasError)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            state.errorText!,
                            style: textTheme.bodySmall!.copyWith(color: themeData.colorScheme.error),
                          ),
                        )
                    ],
                  );
                },
                validator: validateCheckbox,
              ),
            ),
            verticalSpace,
            Align(
                alignment: Alignment.centerLeft,
                child: verticalPersonField(
                    context,
                    lang.comment,
                    personTextFormField(
                        context,
                        (widget.person.comment == '') ? lang.no_comment : widget.person.comment,
                        'Text eingeben',
                        double.infinity),
                    isRequired: false)),
            verticalSpace,
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              oflButton(context, 'zurück', () {
                context.pop();
              }),
              oflButton(context, 'Speichern', () {
                //validate
                if (_key.currentState!.validate()) {
                  //save
                  getLogger().i('validated');
                } else {
                  setState(() {
                    _autoValidate = true;
                  });
                }
              }),
            ]),
            largeVerticalSpacer(),
          ]),
        ),
      ),
    );
  }

  Widget personTextFormField(BuildContext context, String? text, String hintText, double width,
      {String? Function(String)? validator}) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    text = (text != null) ? text : lang.unknown;

    return SizedBox(
      width: width,
      child: TextFormField(
        validator: (text) => (text != null && validator != null) ? validator(text) : null,
        decoration: InputDecoration(
            hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(smallSpace))),
      ),
    );
  }

  Widget salutationRadioGroup() {
    Widget horizontalSpace = smallHorizontalSpacer();

    return Row(children: [
      const Text('männlich'),
      Radio<Gender>(
          value: Gender.male,
          groupValue: _gender,
          onChanged: (Gender? value) {
            if (value != null) {
              setState(() {
                _gender = value;
              });
            }
          }),
      horizontalSpace,
      const Text('weiblich'),
      Radio<Gender>(
          value: Gender.female,
          groupValue: _gender,
          onChanged: (Gender? value) {
            if (value != null) {
              setState(() {
                _gender = value;
              });
            }
          }),
      horizontalSpace,
      const Text('divers'),
      Radio<Gender>(
          value: Gender.diverse,
          groupValue: _gender,
          onChanged: (Gender? value) {
            if (value != null) {
              setState(() {
                _gender = value;
              });
            }
          }),
    ]);
  }

  Widget verticalPersonField(BuildContext context, String label, Widget fieldContent, {bool isRequired = false}) {
    String requiredStar = (isRequired) ? '*' : '';
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:$requiredStar', style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
        smallVerticalSpacer(),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: fieldContent,
        )
      ],
    );
  }

  Row horizontalPersonField(BuildContext context, String label, Widget fieldContent, {bool isRequired = false}) {
    TextTheme textTheme = Theme.of(context).textTheme;
    String requiredStar = (isRequired) ? '*' : '';
    return Row(
      children: [
        Text('$label:$requiredStar', style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
        smallHorizontalSpacer(),
        fieldContent
      ],
    );
  }
}
