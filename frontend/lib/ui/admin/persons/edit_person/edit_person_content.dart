import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/custom_dialog_builder.dart';
import 'package:frontend/ui/admin/commons/input_container.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/person_duplicates_cubit.dart';
import 'package:frontend/ui/admin/persons/edit_person/validators.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/ofl_custom_colors.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class EditPersonContent extends StatefulWidget {
  const EditPersonContent({super.key, required this.viewModel, required this.person, required this.result});

  final EditPersonViewModel viewModel;
  final Person? person;
  final Function(bool) result;

  @override
  State<EditPersonContent> createState() => _EditPersonContentState();
}

class _EditPersonContentState extends State<EditPersonContent> {
  late bool _isEditMode;

  final GlobalKey<FormState> _key = GlobalKey();
  bool _autoValidate = false;
  late PersonDuplicatesBloc duplicatesBloc;

  //TODO: remove controllers - not needed (?)
  // person data states
  late Gender? _gender;
  late bool? _dataProcessingAgreement;
  late String? _email;
  late TextEditingController _emailController;
  late String? _mobileNumber;
  late TextEditingController _mobileNumberController;

  // person data to check name duplicates
  late String _firstName;
  late TextEditingController _firstNameController;
  late String _lastName;
  late TextEditingController _lastNameController;
  String? _dateOfBirth;
  late TextEditingController _dateOfBirthController;

  // person data to check address duplicates
  late String _streetNameNumber;
  late TextEditingController _streetNameNumberController;
  late String _addressSuffix;
  late TextEditingController _addressSuffixController;
  late String _postalCode;
  late TextEditingController _postalCodeController;

  late String _comment;
  late TextEditingController _commentController;

  @override
  void initState() {
    // set bool for edit mode (or new person mode)
    _isEditMode = widget.person != null;

    // agreement has to be given for both, new person or edit person
    _dataProcessingAgreement = false;

    //initialize duplicatesBloc
    duplicatesBloc = sl<PersonDuplicatesBloc>();

    // set initial values for person data
    // FIXME: if-else before produced NPE, also, unsure if late is necessary
    _gender = Gender.diverse;
    _email = '';
    _mobileNumber = '';
    _firstName = '';
    _lastName = '';
    _streetNameNumber = '';
    _addressSuffix = '';
    _postalCode = '';
    _comment = '';

    if (_isEditMode) {
      _gender = widget.person!.gender;
      _email = widget.person!.email;
      _mobileNumber = widget.person!.mobileNumber;
      _firstName = widget.person!.firstName;
      _lastName = widget.person!.lastName;
      if (widget.person!.address != null) {
        _streetNameNumber = widget.person!.address!.streetNameNumber;
        _addressSuffix = widget.person!.address!.addressSuffix;
        _postalCode = widget.person!.address!.postalCode;
      }
      _comment = widget.person!.comment;
    }

    _firstNameController = TextEditingController(text: _firstName);
    _lastNameController = TextEditingController(text: _lastName);
    _dateOfBirthController = TextEditingController();
    _streetNameNumberController = TextEditingController(text: _streetNameNumber);
    _addressSuffixController = TextEditingController(text: _addressSuffix);
    _postalCodeController = TextEditingController(text: _postalCode);
    _emailController = TextEditingController(text: _email);
    _mobileNumberController = TextEditingController(text: _mobileNumber);
    _commentController = TextEditingController(text: _comment);
    _dateOfBirthController = TextEditingController(text: _dateOfBirth);

    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    // initialize _dateOfBirth when started in edit mode - initial state, when _dateOfBirth is null
    if (_isEditMode && _dateOfBirth == null && getFormattedDateAsString(context, widget.person!.dateOfBirth) != null) {
      _dateOfBirth = getFormattedDateAsString(context, widget.person!.dateOfBirth)!;
      _dateOfBirthController = TextEditingController(text: _dateOfBirth);
    }
    // initialize _dateOfBirth when started in new person mode (!_editMode) - initial state, when _dateOfBirth is null
    else if (!_isEditMode && _dateOfBirth == null) {
      _dateOfBirth = '';
      _dateOfBirthController = TextEditingController(text: _dateOfBirth);
    }

    //method to check for duplicates when all relevant fields are filled out correctly
    void getDuplicates() {
      DateTime? date;
      if (_dateOfBirth != null) {
        date = getFormattedDateTime(context, _dateOfBirth!);
      }
      if (_firstName != '' && _lastName != '' && date != null) {
        duplicatesBloc.add(SearchDuplicateEvent(_firstName, _lastName, date));
      }
    }

    Widget verticalSpace = mediumVerticalSpacer();
    Widget horizontalSpace = mediumHorizontalSpacer();

    double horizontalPadding = 200;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Form(
          key: _key,
          autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: horizontalPadding),
              formBody(context, verticalSpace, getDuplicates, horizontalSpace, duplicatesBloc),
              duplicatesColumn(horizontalPadding, duplicatesBloc),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox duplicatesColumn(double horizontalPadding, PersonDuplicatesBloc duplicatesBloc) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: horizontalPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 140),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<PersonDuplicatesBloc, PersonDuplicatesState>(
              bloc: duplicatesBloc,
              builder: (context, state) {
                if (state is PersonDuplicatesLoading) {
                  return const CircularProgressIndicator();
                } else if (state is PersonDuplicatesLoaded) {
                  if (state.duplicates.isEmpty) {
                    return Row(
                      children: [
                        Icon(Icons.check_circle, color: successColor),
                        smallHorizontalSpacer(),
                        Text(lang.no_duplicates, style: textTheme.bodyMedium),
                      ],
                    );
                  } else if (state.duplicates.length == 1) {
                    return Row(
                      children: [
                        Icon(Icons.warning, color: warningColor),
                        smallHorizontalSpacer(),
                        Text(lang.duplicate_found, style: textTheme.bodyMedium),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Icon(Icons.warning, color: warningColor),
                        smallHorizontalSpacer(),
                        Text('${state.duplicates.length} ${lang.duplicates_found}', style: textTheme.bodyMedium),
                      ],
                    );
                  }
                } else if (state is PersonDuplicatesError) {
                  return Text('Error: ${state.error}');
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Expanded formBody(BuildContext context, Widget verticalSpace, void Function() getDuplicates, Widget horizontalSpace,
      PersonDuplicatesBloc duplicatesBloc) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Expanded(
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        titleRow(lang, textTheme),
        largeVerticalSpacer(),
        genderRow(context, lang),
        verticalSpace,
        nameRow(context, lang, getDuplicates, horizontalSpace),
        verticalSpace,
        addressRow(context, lang, horizontalSpace),
        verticalSpace,
        const Divider(),
        verticalSpace,
        contactDetailsRow(lang, textTheme, verticalSpace, context, themeData),
        verticalSpace,
        dataAgreementRow(context, lang, textTheme, themeData),
        verticalSpace,
        commentRow(context, lang),
        verticalSpace,
        duplicatesListBlocBuilder(duplicatesBloc, lang, textTheme, themeData),
        buttonsRow(context, lang, _isEditMode),
        largeVerticalSpacer(),
      ]),
    );
  }

  Row buttonsRow(BuildContext context, AppLocalizations lang, bool isEditMode) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      oflButton(context, lang.back, () {
        context.pop();
      }),
      BlocConsumer<EditPersonViewModel, EditPersonState>(
        bloc: widget.viewModel,
        listener: (context, state) {
          String dialogText = '';
          if (_isEditMode) {
            dialogText = lang.person_successfully_edited;
          } else {
            dialogText = lang.person_successfully_created;
          }
          if (state is EditPersonLoaded) {
            customDialogBuilder(context, dialogText, successColor);
          } else if (state is EditPersonError) {
            customDialogBuilder(context, dialogText, errorColor);
          } else if (state is EditPersonComplete) {
            //pop twice, because first pop dialog builder and then pop this page
            context.pop();
            widget.result.call(true);
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is EditPersonLoading) {
            return const CircularProgressIndicator();
          }
          return oflButton(context, lang.save, () {
            if (_key.currentState!.validate()) {
              if (isEditMode) {
                widget.viewModel.editPerson(
                  firstName: _firstName,
                  lastName: _lastName,
                  dateOfBirth: getFormattedDateTime(context, _dateOfBirth!),
                  gender: _gender,
                  streetNameNumber: _streetNameNumber,
                  addressSuffix: _addressSuffix,
                  postalCode: _postalCode,
                  email: _email,
                  mobileNumber: _mobileNumber,
                  comment: _comment,
                );
              } else {
                widget.viewModel.createPerson(
                    firstName: _firstName,
                    lastName: _lastName,
                    dateOfBirth: getFormattedDateTime(context, _dateOfBirth!)!,
                    gender: _gender!,
                    streetNameNumber: _streetNameNumber,
                    addressSuffix: _addressSuffix,
                    postalCode: _postalCode,
                    email: _email,
                    mobileNumber: _mobileNumber,
                    comment: _comment);
              }
            } else {
              setState(() {
                _autoValidate = true;
              });
            }
          });
        },
      ),
    ]);
  }

  BlocBuilder<PersonDuplicatesBloc, PersonDuplicatesState> duplicatesListBlocBuilder(
      PersonDuplicatesBloc duplicatesBloc, AppLocalizations lang, TextTheme textTheme, ThemeData themeData) {
    return BlocBuilder<PersonDuplicatesBloc, PersonDuplicatesState>(
        bloc: duplicatesBloc,
        builder: (context, state) {
          if (state is PersonDuplicatesLoaded) {
            if (state.duplicates.length == 1) {
              Person duplicatePerson = state.duplicates[0];
              return Column(
                children: [
                  Text('${lang.duplicate_found}:',
                      style: textTheme.bodyLarge!.copyWith(color: themeData.colorScheme.error)),
                  InkWell(
                    onTap: () {
                      context.goNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': duplicatePerson.id});
                    },
                    child: duplicatePersonText(duplicatePerson, context),
                  )
                ],
              );
            } else if (state.duplicates.length > 1) {
              return Column(
                children: [
                  Text(lang.duplicates_found, style: textTheme.bodyLarge!.copyWith(color: themeData.colorScheme.error)),
                  smallVerticalSpacer(),
                  ...state.duplicates.map((person) => InkWell(
                        onTap: () {
                          context.goNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': person.id});
                        },
                        child: duplicatePersonText(person, context),
                      ))
                ],
              );
            } else {
              return const SizedBox();
            }
          } else {
            return const SizedBox();
          }
        });
  }

  Row commentRow(BuildContext context, AppLocalizations lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: verticalPersonField(
              context,
              lang.comment,
              personTextFormField(context, lang.hint_insert_text, double.infinity, controller: _commentController,
                  onChanged: (value) {
                _comment = value;
              }),
              isRequired: false),
        ),
      ],
    );
  }

  Align dataAgreementRow(BuildContext context, AppLocalizations lang, TextTheme textTheme, ThemeData themeData) {
    return Align(
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
                  child: SelectableText(
                    state.errorText!,
                    style: textTheme.bodySmall!.copyWith(color: themeData.colorScheme.error),
                  ),
                ),
            ],
          );
        },
        validator: (value) => validateDataProcessingCheckbox(value, lang),
      ),
    );
  }

  FormField<ContactDetails> contactDetailsRow(
      AppLocalizations lang, TextTheme textTheme, Widget verticalSpace, BuildContext context, ThemeData themeData) {
    return FormField<ContactDetails>(
        initialValue: ContactDetails(email: _email, mobileNumber: _mobileNumber),
        validator: (value) => validateEmailAndPhoneNumber(value, lang),
        builder: (FormFieldState<ContactDetails> state) {
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(lang.error_insert_email_mobile, style: textTheme.bodyMedium),
              ),
              verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: verticalPersonField(
                      context,
                      lang.email_address,
                      TextField(
                        controller: _emailController,
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
                        controller: _mobileNumberController,
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
                  child: SelectableText(
                    state.errorText!,
                    style: textTheme.bodySmall!.copyWith(color: themeData.colorScheme.error),
                  ),
                )
            ],
          );
        });
  }

  Row addressRow(BuildContext context, AppLocalizations lang, Widget horizontalSpace) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: verticalPersonField(
              context,
              lang.street_housenumber,
              personTextFormField(
                context,
                lang.hint_insert_text,
                largeFormFieldWidth,
                validator: (value) => validateName(value, lang),
                controller: _streetNameNumberController,
                onChanged: (value) {
                  _streetNameNumber = value;
                },
              ),
              isRequired: true),
        ),
        horizontalSpace,
        Expanded(
          child: verticalPersonField(
              context,
              lang.stairs_door,
              personTextFormField(
                context,
                lang.hint_address_suffix,
                smallFormFieldWidth,
                controller: _addressSuffixController,
                onChanged: (value) {
                  _addressSuffix = value;
                },
              ),
              isRequired: false),
        ),
        horizontalSpace,
        Expanded(
          child: verticalPersonField(
              context,
              lang.zip,
              personTextFormField(
                context,
                lang.hint_number,
                smallFormFieldWidth,
                validator: (value) => validateNumber(value, lang),
                controller: _postalCodeController,
                onChanged: (value) {
                  _postalCode = value;
                },
              ),
              isRequired: true),
        ),
      ],
    );
  }

  Row nameRow(BuildContext context, AppLocalizations lang, void Function() getDuplicates, Widget horizontalSpace) {
    return Row(
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
                  validator: (date) => validateDate(date, context),
                  controller: _dateOfBirthController,
                  onChanged: (date) {
                    _dateOfBirth = date;

                    if (validateDate(date, context) == null) {
                      getDuplicates();
                    }
                  }),
              isRequired: true),
        ),
        horizontalSpace,
      ],
    );
  }

  Row genderRow(BuildContext context, AppLocalizations lang) {
    return horizontalPersonField(
      context,
      lang.gender,
      salutationRadioGroup(lang),
    );
  }

  Row titleRow(AppLocalizations lang, TextTheme textTheme) {
    return Row(
      children: [
        if (_isEditMode)
          Text(lang.edit_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold))
        else
          Text(lang.create_new_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Text duplicatePersonText(Person duplicatePerson, BuildContext context) {
    return Text(
      '${duplicatePerson.firstName} ${duplicatePerson.lastName} '
      '[${getFormattedDateAsString(context, duplicatePerson.dateOfBirth)}]',
      style: const TextStyle(
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget salutationRadioGroup(AppLocalizations lang) {
    Widget horizontalSpace = const SizedBox(width: 10);

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
      mainAxisAlignment: MainAxisAlignment.start,
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
