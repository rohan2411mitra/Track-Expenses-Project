import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextFormField reusableTextField(String text, IconData icon, bool isPassword,
    TextEditingController controller,
    {bool isName = false}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    enableSuggestions: !isPassword,
    autocorrect: !isPassword,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        labelText: text,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none))),
    keyboardType:
        isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (input) => (isPassword
        ? (input == null || input.isEmpty
            ? 'Password field cannot be empty'
            : input.length < 6
                ? 'Password should be at least 6 characters'
                : null)
        : (isName
            ? (input == null || input.isEmpty
                ? 'User Name cannot be empty'
                : null)
            : (input == null || input.isEmpty
                ? 'Email field cannot be empty'
                : !EmailValidator.validate(input)
                    ? 'Please enter a valid email address'
                    : null))),
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      child: Text(
        isLogin ? 'LOG IN' : 'SIGN UP',
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}

MaterialColor catColor(String input) {
  if (input == 'Work') {
    return Colors.orange;
  } else if (input == 'Personal') {
    return Colors.teal;
  } else if (input == 'Transport') {
    return Colors.lightGreen;
  } else {
    return Colors.indigo;
  }
}

Card item(DocumentSnapshot transaction) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      textColor: Colors.black,
      leading: Image.asset("assets/images/${transaction["Pay_Method"]}.png",
          height: 40),
      title: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: catColor(transaction["Category"]),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                transaction['Note'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For ${transaction['Category']}',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: catColor(transaction['Category']).shade600),
          ),
          Text(
            DateFormat('dd/MM/yyyy')
                .format(transaction['Date'].toDate().toLocal()),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Text(
        '\u{20B9} ${transaction["Amount"]}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: (transaction['Payment_Type'] == "Income")
              ? Colors.green.shade700
              : Colors.red,
        ),
      ),
    ),
  );
}

Widget transactions(
    CollectionReference transactions, String order, bool descending,
    {bool condition = true}) {
  return StreamBuilder(
    stream: transactions.orderBy(order, descending: descending).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text("Something Went Wrong! ${snapshot.error}"));
      } else if (snapshot.hasData) {
        final transactions = snapshot.data!;

        if (transactions.docs.isEmpty) {
          return const Center(
            child: Text(
              "No Transaction added yet!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: (transactions.docs.length > 10 && condition)
                ? 10
                : transactions.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot transaction = transactions.docs[index];
              return item(transaction);
            },
          );
        }
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(BuildContext context, String message, String color){
  return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
    content: Text(message,
        textAlign: TextAlign.center),
    duration: const Duration(seconds: 4),
    backgroundColor: (color=="red") ? Colors.red : Colors.green,
  ));
}