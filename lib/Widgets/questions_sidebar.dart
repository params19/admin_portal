import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/questions_download.dart';
import '../constants/constants.dart';

class QuestionsSidebar extends StatefulWidget {
  final List<String> questions;
  final Function(int) onQuestionSelected;
  final Function(int) onDeleteQuestion;
  final Function(List<String>) onSaveQuestions;
  final Function(String, List<String>, String, String, String) onAddNewQuestion;
  final String subject;

  const QuestionsSidebar({
    Key? key,
    required this.questions,
    required this.onQuestionSelected,
    required this.onDeleteQuestion,
    required this.onSaveQuestions,
    required this.onAddNewQuestion,
    required this.subject,
  }) : super(key: key);

  @override
  _QuestionsSidebarState createState() => _QuestionsSidebarState();
}

class _QuestionsSidebarState extends State<QuestionsSidebar> {
  int selectedIndex = -1;
  TextEditingController _questionController = TextEditingController();
  TextEditingController _option1Controller = TextEditingController();
  TextEditingController _option2Controller = TextEditingController();
  TextEditingController _option3Controller = TextEditingController();
  TextEditingController _option4Controller = TextEditingController();
  TextEditingController _correctAnswerController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _questionIdController = TextEditingController();
  TextEditingController _questionUpdateController = TextEditingController();
  TextEditingController _option1UpdateController = TextEditingController();
  TextEditingController _option2UpdateController = TextEditingController();
  TextEditingController _option3UpdateController = TextEditingController();
  TextEditingController _option4UpdateController = TextEditingController();
  TextEditingController _correctAnswerUpdateController = TextEditingController();
  TextEditingController _descriptionUpdateController = TextEditingController();
  TextEditingController _questionIdUpdateController = TextEditingController();
  GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  Future<void> saveQuestionId(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> questionIds = prefs.getStringList('questionIds') ?? [];
    questionIds.add(questionId);
    await prefs.setStringList('questionIds', questionIds);
  }

  Future<List<String>> getQuestionIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('questionIds') ?? [];
  }

  Future<void> deleteQuestion(String quesId, Function refreshQuestions) async {
    var apiUrl = 'https://cine-admin-xar9.onrender.com/admin/deleteQuestion';

    var request = http.Request('DELETE', Uri.parse(apiUrl));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'quesId': quesId,
    });

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              'Question deleted successfully',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2), // Show snackbar for 2 seconds
          ),
        );
        Future.delayed(Duration(seconds: 2), () {
          refreshQuestions();
        });

        print(await response.stream.bytesToString());
      } else {
        print('Failed with status: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception during DELETE request: $e');
    }
  }

  void showAddQuestionDialog() {
    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();
    _option4Controller.clear();
    _correctAnswerController.clear();
    _descriptionController.clear();
    _questionIdController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Question',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Enter your question',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  _buildOptionTextField(_option1Controller, "Option 1", "1"),
                  SizedBox(height: 12.0),
                  _buildOptionTextField(_option2Controller, "Option 2", "2"),
                  SizedBox(height: 12.0),
                  _buildOptionTextField(_option3Controller, "Option 3", "3"),
                  SizedBox(height: 12.0),
                  _buildOptionTextField(_option4Controller, "Option 4", "4"),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _correctAnswerController,
                    decoration: InputDecoration(
                      hintText: 'Correct Answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _questionIdController,
                    decoration: InputDecoration(
                      hintText: 'Question ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 12.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_questionController.text.isNotEmpty &&
                              _option1Controller.text.isNotEmpty &&
                              _option2Controller.text.isNotEmpty &&
                              _option3Controller.text.isNotEmpty &&
                              _option4Controller.text.isNotEmpty &&
                              _correctAnswerController.text.isNotEmpty &&
                              _descriptionController.text.isNotEmpty &&
                              _questionIdController.text.isNotEmpty) {
                            String question = _questionController.text;
                            List<Map<String, String>> options = [
                              {"desc": _option1Controller.text, "id": "1"},
                              {"desc": _option2Controller.text, "id": "2"},
                              {"desc": _option3Controller.text, "id": "3"},
                              {"desc": _option4Controller.text, "id": "4"},
                            ];
                            String correctAnswer =
                                _correctAnswerController.text;
                            String description = _descriptionController.text;
                            String questionId = _questionIdController.text;

                            var response = await http.post(
                              Uri.parse(
                                  'https://cine-admin-xar9.onrender.com/admin/addQuestion'),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "question": question,
                                "options": options
                                    .map((option) => {
                                          "desc": option["desc"],
                                          "id": option["id"]
                                        })
                                    .toList(),
                                "subject": widget.subject,
                                "quesId": questionId,
                                "answer": correctAnswer,
                                "description": description,
                              }),
                            );

                            print('Response status: ${response.statusCode}');
                            print('Response body: ${response.body}');

                            if (response.statusCode == 201) {
                              widget.onAddNewQuestion(
                                question,
                                options
                                    .map((option) => option['desc'] ?? "")
                                    .toList(),
                                correctAnswer,
                                description,
                                questionId,
                              );

                              // Save the new question ID to SharedPreferences
                              await saveQuestionId(questionId);
                              List<String> savedIds = await getQuestionIds();
                              print('Question IDs saved: $savedIds');

                              Navigator.of(context).pop();
                            } else {
                              if (response.statusCode == 500) {
                                print('Internal server error occurred');
                              } else {
                                print('Failed to add question');
                              }
                            }
                          }
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTextField(
      TextEditingController controller, String hintText, String id) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      onChanged: (_) => setState(() {}),
    );
  }

  void _loadQuestions() {
    // Implement your logic to fetch updated questions here
    // For example:
    // List<String> updatedQuestions = fetchQuestionsFromServer();
    // setState(() {
    //   widget.questions = updatedQuestions;
    // });
  }

  @override
  Widget build(BuildContext context) {
    double heightFactor = MediaQuery.of(context).size.height / 1024;
    double widthFactor = MediaQuery.of(context).size.width / 1440;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: heightFactor * 80,
            padding: EdgeInsets.all(10 * heightFactor),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Question",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24 * widthFactor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 20 * heightFactor),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10 * heightFactor),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10 * heightFactor,
                crossAxisSpacing: 10 * widthFactor,
              ),
              itemCount: widget.questions.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.questions.length) {
                  return GestureDetector(
                    onTap: showAddQuestionDialog,
                    child: Container(
                      width: 60 * widthFactor,
                      height: 60 * heightFactor,
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add,
                        color: primaryColor,
                        size: 30 * widthFactor,
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedIndex = index;
                        widget.onQuestionSelected(index);
                      });
                      List<String> savedIds = await getQuestionIds();
                      if (index < savedIds.length) {
                        String questionId = savedIds[index];
                        print('Clicked question ID: $questionId');
                      } else {
                        print('No question ID found for index $index');
                      }
                    },
                    child: Container(
                      width: 60 * widthFactor,
                      height: 60 * heightFactor,
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : primaryColor,
                          fontSize: 18 * widthFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 20 * heightFactor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (selectedIndex != -1) {
                    // Get question ID based on selectedIndex
                    List<String> savedIds = await getQuestionIds();
                    if (selectedIndex < savedIds.length) {
                      String questionId = savedIds[selectedIndex];
                      deleteQuestion(questionId,
                          _loadQuestions); // Call deleteQuestion with question ID and refresh function
                      widget.onDeleteQuestion(selectedIndex);
                    } else {
                      print('No question ID found for index $selectedIndex');
                    }
                  } else {
                    print('No question selected to delete');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * widthFactor,
                    vertical: 10 * heightFactor,
                  ),
                ),
                child: Text(
                  "Delete",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: widthFactor * 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_questionUpdateController.text.isNotEmpty &&
                      _option1UpdateController.text.isNotEmpty &&
                      _option2UpdateController.text.isNotEmpty &&
                      _option3UpdateController.text.isNotEmpty &&
                      _option4UpdateController.text.isNotEmpty &&
                      _correctAnswerUpdateController.text.isNotEmpty 
                      // _descriptionController.text.isNotEmpty &&
                      // _questionIdController.text.isNotEmpty
                      ) {
                    String question = _questionUpdateController.text;
                    List<Map<String, String>> options = [
                      {"desc": _option1UpdateController.text, "id": "1"},
                      {"desc": _option2UpdateController.text, "id": "2"},
                      {"desc": _option3UpdateController.text, "id": "3"},
                      {"desc": _option4UpdateController.text, "id": "4"},
                    ];
                    String correctAnswer = _correctAnswerController.text;
                    // String description = _descriptionController.text;
                    String questionId='';
                    
                    if (selectedIndex != -1) {
                      // Get question ID based on selectedIndex
                      List<String> savedIds = await getQuestionIds();
                      if (selectedIndex < savedIds.length) {
                         questionId = savedIds[selectedIndex];
                        // deleteQuestion(questionId,
                        //     _loadQuestions); // Call deleteQuestion with question ID and refresh function
                        widget.onDeleteQuestion(selectedIndex);
                      } else {
                        print('No question ID found for index $selectedIndex');
                      }
                    } else {
                      print('No question selected to delete');
                    }

                    var response = await http.patch(
                      Uri.parse(
                          'https://cine-admin-xar9.onrender.com/admin/updateQuestion'),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "question": question,
                        "options": options
                            .map((option) =>
                                {"desc": option["desc"], "id": option["id"]})
                            .toList(),
                        "subject": widget.subject,

                        "quesId": '${questionId}',
                        "answer": correctAnswer,
                        // "description": description,
                      }),
                    );

                    print('Response status: ${response.statusCode}');
                    print('Response body: ${response.body}');

                    if (response.statusCode == 201) {
                      // widget.onAddNewQuestion(
                      //   question,
                      //   options.map((option) => option['desc'] ?? "").toList(),
                      //   correctAnswer,
                      //   // description,
                      //   questionId,
                      // );

                      // Save the new question ID to SharedPreferences
                      await saveQuestionId(questionId);
                      List<String> savedIds = await getQuestionIds();
                      print('Question IDs saved: $savedIds');

                      Navigator.of(context).pop();
                    } else {
                      if (response.statusCode == 500) {
                        print('Internal server error occurred');
                      } else {
                        print('Failed to add question');
                      }
                    }
                  }
                },
                //  () {
                //   widget.onSaveQuestions(widget.questions);
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => QuestionsDownload(
                //             savedQuestions: widget.questions)),
                //   );
                // },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * widthFactor,
                    vertical: 10 * heightFactor,
                  ),
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: widthFactor * 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
