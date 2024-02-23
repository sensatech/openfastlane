import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/edit_person/person_duplicates_cubit.dart';
import 'package:frontend/ui/admin/persons/person_view/validators.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/spacer.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class EditPersonContent extends StatefulWidget {
  const EditPersonContent({super.key, required this.person});

  final Person? person;

  @override
  State<EditPersonContent> createState() => _EditPersonContentState();
}

class _EditPersonContentState extends State<EditPersonContent> {
  final GlobalKey<FormState> _key = GlobalKey();
  bool _autoValidate = false;

  // person data states
  late Gender? _gender;
  late bool? _dataProcessingAgreement;
  late String? _email;
  late String? _mobileNumber;

  // person data
  late String _firstName;
  late TextEditingController _firstNameController;
  late String _lastName;
  late TextEditingController _lastNameController;
  DateTime? _dateOfBirth;
  late TextEditingController _dateOfBirthController;

  @override
  void initState() {
    _dataProcessingAgreement = false;
    if (widget.person == null) {
      _gender = Gender.male;
      _email = '';
      _mobileNumber = '';
      _firstName = '';
      _lastName = '';
    } else {
      _gender = widget.person!.gender;
      _email = widget.person!.email;
      _mobileNumber = widget.person!.mobileNumber;
      _firstName = widget.person!.firstName;
      _lastName = widget.person!.lastName;
      _dateOfBirth = widget.person!.dateOfBirth;
    }

    _firstNameController = TextEditingController(text: _firstName);
    _lastNameController = TextEditingController(text: _lastName);
    _dateOfBirthController = TextEditingController();

    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    PersonDuplicatesBloc duplicatesCubit = sl<PersonDuplicatesBloc>();

    if (_dateOfBirth != null) {
      _dateOfBirthController = TextEditingController(text: getFormattedDate(context, _dateOfBirth!));
    }

    void getDuplicates() {
      if (_firstName != '' && _lastName != '' && _dateOfBirth != null) {
        duplicatesCubit.add(SearchDuplicateEvent(_firstName, _lastName, _dateOfBirth!));
      }
    }

    AppLocalizations lang = AppLocalizations.of(context)!;
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;

    Widget verticalSpace = mediumVerticalSpacer();
    Widget horizontalSpace = mediumHorizontalSpacer();

    double smallFormFieldWidth = 200;
    double mediumFormFieldWidth = 300;
    double largeFormFieldWidth = 400;

    double horizontalPadding = 100;
    return Form(
      key: _key,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Row(
        children: [
          SizedBox(width: horizontalPadding),
          Expanded(
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
                  salutationRadioGroup(lang),
                ),
                verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: verticalPersonField(
                          context,
                          lang.firstname,
                          personTextFormField(context, lang.hint_insert_text, mediumFormFieldWidth,
                              validator: (value) => validateName(value, lang),
                              controller: _firstNameController,
                              onChanged: (value) {
                                _firstName = value;
                                getDuplicates();
                              }),
                          isRequired: true),
                    ),
                    horizontalSpace,
                    Expanded(
                      child: verticalPersonField(
                          context,
                          lang.lastname,
                          personTextFormField(context, lang.hint_insert_text, mediumFormFieldWidth,
                              validator: (value) => validateName(value, lang),
                              controller: _lastNameController,
                              onChanged: (value) {
                                _lastName = value;
                                getDuplicates();
                              }),
                          isRequired: true),
                    ),
                    horizontalSpace,
                    Expanded(
                      child: verticalPersonField(
                          context,
                          lang.birthdate,
                          personTextFormField(context, lang.hint_date_format, mediumFormFieldWidth,
                              validator: (value) => validateDate(value, lang),
                              controller: _dateOfBirthController,
                              onChanged: (value) => getDuplicates()),
                          isRequired: true),
                    ),
                    horizontalSpace,
                    SizedBox(
                      width: horizontalPadding,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: BlocBuilder<PersonDuplicatesBloc, PersonDuplicatesState>(
                            bloc: duplicatesCubit,
                            builder: (context, state) {
                              if (state is PersonDuplicatesLoading) {
                                return const CircularProgressIndicator();
                              } else if (state is PersonDuplicatesLoaded) {
                                return Text('Duplicates: ${state.duplicates.length}');
                              } else {
                                return const Text('No duplicates');
                              }
                            },
                          ),
                        ),
                      ),
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
                          personTextFormField(context, lang.hint_insert_text, largeFormFieldWidth,
                              validator: (value) => validateName(value, lang)),
                          isRequired: true),
                    ),
                    horizontalSpace,
                    Expanded(
                      child: verticalPersonField(
                          context,
                          lang.stairs_door,
                          personTextFormField(context, lang.hint_address_suffix, smallFormFieldWidth,
                              validator: (value) => validateName(value, lang)),
                          isRequired: true),
                    ),
                    horizontalSpace,
                    Expanded(
                      child: verticalPersonField(
                          context,
                          lang.zip,
                          personTextFormField(context, lang.hint_number, smallFormFieldWidth,
                              validator: (value) => validateNumber(value, lang)),
                          isRequired: true),
                    ),
                    SizedBox(width: horizontalPadding),
                  ],
                ),
                verticalSpace,
                const Divider(),
                verticalSpace,
                FormField<ContactDetails>(
                    validator: (value) => validateEmailAndPhoneNumber(value, lang),
                    builder: (FormFieldState<ContactDetails> state) {
                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(lang.error_insert_email_mobile, style: textTheme.bodyMedium),
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
                              SizedBox(width: horizontalPadding),
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
                            lang.accept_terms,
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
                                Text(lang.yes)
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
                            ),
                          SizedBox(width: horizontalPadding),
                        ],
                      );
                    },
                    validator: (value) => validateCheckbox(value, lang),
                  ),
                ),
                verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: verticalPersonField(
                          context, lang.comment, personTextFormField(context, lang.hint_insert_text, double.infinity),
                          isRequired: false),
                    ),
                    SizedBox(width: horizontalPadding),
                  ],
                ),
                verticalSpace,
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  oflButton(context, lang.back, () {
                    context.pop();
                  }),
                  oflButton(context, lang.save, () {
                    //validate
                    if (_key.currentState!.validate()) {
                      //TODO: add action, when validation is successful
                      getLogger().i('validated');
                    } else {
                      setState(() {
                        _autoValidate = true;
                      });
                    }
                  }),
                  SizedBox(width: horizontalPadding),
                ]),
                largeVerticalSpacer(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget personTextFormField(BuildContext context, String hintText, double width,
      {String? Function(String)? validator, TextEditingController? controller, void Function(String)? onChanged}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        validator: (text) => (text != null && validator != null) ? validator(text) : null,
        decoration: InputDecoration(
            hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(smallSpace))),
        onChanged: onChanged,
      ),
    );
  }

  Widget salutationRadioGroup(AppLocalizations lang) {
    Widget horizontalSpace = smallHorizontalSpacer();

    return Row(children: [
      Text(lang.male),
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
      Text(lang.female),
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
      Text(lang.diverse),
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
