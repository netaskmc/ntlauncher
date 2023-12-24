import 'package:flutter/material.dart';
import 'package:ntlauncher/java/manager.dart';
import 'package:ntlauncher/ui/dialog.dart';

class JavaFinder extends StatelessWidget {
  const JavaFinder({
    super.key,
    required this.onConfirm,
  });

  final Function(JavaInstance) onConfirm;

  @override
  Widget build(BuildContext context) {
    return NtDialog(
      title: const Text("Find Java"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: JavaManager.findInstances(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data!.map((e) {
                    return ListTile(
                      title: Row(
                        children: [
                          Text(e.version,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 4),
                          Text(
                            "(${e.arch}) by ${e.vendor}",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 216, 216, 216),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        e.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        onConfirm(e);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
