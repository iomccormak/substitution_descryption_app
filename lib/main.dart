import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const SubstitutionCipherApp());
}

class SubstitutionCipherApp extends StatelessWidget {
  const SubstitutionCipherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const DefaultTextHeightBehavior(
          textHeightBehavior: TextHeightBehavior(
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: CipherScreen(),
          ),
        );
      },
    );
  }
}

class CipherScreen extends StatefulWidget {
  const CipherScreen({super.key});

  @override
  _CipherScreenState createState() => _CipherScreenState();
}

class _CipherScreenState extends State<CipherScreen> {
  final TextEditingController _textController = TextEditingController();
  final Map<String, String> _substitutions = Map.fromIterables(
      List.generate(32, (index) => String.fromCharCode(1072 + index)),
      List.generate(32, (_) => ''));
  final List<FocusNode> _focusNodes = List.generate(32, (_) => FocusNode());
  String _result = '';

  void _applyCipher() {
    String inputText = _textController.text;
    String outputText = inputText.split('').map((char) {
      if (_substitutions.containsKey(char.toLowerCase())) {
        String? replacement = _substitutions[char.toLowerCase()];
        if (replacement != null && replacement.isNotEmpty) {
          return char == char.toLowerCase()
              ? replacement
              : replacement.toUpperCase();
        }
      }
      return char;
    }).join('');

    setState(() {
      _result = outputText;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 32.h),
              Text(
                'Шифрование методом простой замены',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27.sp,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Введите текст для шифрования',
                  filled: true,
                  fillColor: Color.fromARGB(12, 0, 0, 0),
                  border: InputBorder.none,
                ),
                maxLines: 10,
              ),
              SizedBox(height: 32.h),
              Text(
                'Таблица замен:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 4,
                ),
                itemCount: _substitutions.keys.length,
                itemBuilder: (context, index) {
                  String originalChar = _substitutions.keys.elementAt(index);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30.w,
                        height: 27.h,
                        child: Align(
                          child: Text(
                            '$originalChar ->',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 43.w,
                        child: TextField(
                          maxLength: 1,
                          focusNode: _focusNodes[index],
                          onChanged: (value) {
                            setState(() {
                              _substitutions[originalChar] = value;
                            });
                            if (value.length == 1 &&
                                index + 1 < _focusNodes.length) {
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[index + 1]);
                            }
                          },
                          decoration: const InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Color.fromARGB(12, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyCipher,
                  child: Text(
                    'Применить',
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Результат:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                _result,
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
