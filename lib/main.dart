import 'package:chat_diver/components/conversation_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/date_picker.dart';
import 'components/filter_button.dart';
import 'controllers/app_controller.dart';
import 'controllers/filter_controller.dart';

// TO-DO:

// - text search agent/traveler tri-toggle
// - text search combine terms option
// - address date sorting errors
// - quotation mark handling in text
// - multi-csat not working (CATI)
// - Nov 11-17 chat #15 throws null error until you separate out the CATI interaction from the primary.

// POST APPROVAL:
// - build for macOS
// - Add "see other chats" pop-up on right click.
// - connect to Snowflake
// - TripActions skin
// - look into trascribing
// - implement translation
// - implement language filter
// - timestamp popup = (convert times into agent local time, add time zone)

void main() async {
  runApp(GetMaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // initiate controllers (GetX package)
  final FilterController filterController = Get.put(FilterController());
  final AppController appController = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    ConversationView? conversationView;

    // set window size restrictions
    appController.constrictWindow();

    //begin initial import
    Future<bool> _imported = appController.import();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //TripActions Blue as default color
        primaryColor: const Color.fromRGBO(2, 146, 254, 1),
      ),
      home: Scaffold(
        // create app header widgets
        appBar: AppBar(
          leading: FilterButton(),
          title: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Tooltip(
                  message: 'Scanning Chats Using Better Analytics',
                  child: SelectableText('SCUBA'),
                ),
                (appController.chats.isNotEmpty)
                    ? SelectableText(
                        ': Showing Chat ${appController.conversationToShow.value + 1} of ${appController.chats.length}')
                    : Container()
              ],
            ),
          ),
        ),
        body: FutureBuilder(
            future: _imported,
            builder: (context, snap) {
              if (snap.hasData) {
                return Obx(() => Container(
                    child: (appController.chats.isNotEmpty)
                        ? Stack(
                            children: [
                              Center(
                                child: Obx(() {
                                  conversationView = ConversationView(
                                      appController.chats[
                                          appController.chats.keys.toList()[
                                              appController
                                                  .conversationToShow.value]]!);
                                  return conversationView!;
                                }),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Spacer(
                                      flex: 2,
                                    ),
                                    FloatingActionButton(
                                        child: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          if (appController
                                                  .conversationToShow.value >
                                              0) {
                                            appController.decrement();
                                            conversationView?.controller
                                                .jumpTo(0);
                                          }
                                        }),
                                    const Spacer(flex: 7),
                                    FloatingActionButton(
                                        child: const Icon(Icons.arrow_forward),
                                        onPressed: () {
                                          if (appController
                                                  .conversationToShow.value <
                                              appController.chats.length - 1) {
                                            appController.increment();
                                            conversationView?.controller
                                                .jumpTo(0);
                                          }
                                        }),
                                    const Spacer(flex: 2),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Flexible(
                                  child: SelectableText(
                                      'Welcome to SCUBA, your favorite tool for analyzing chat content!\n'),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Flexible(
                                      child: Tooltip(
                                        message:
                                            'Click to change active filters',
                                        child: SelectableText(
                                            'If you want to set filters, use the icon that looks like this: '),
                                      ),
                                    ),
                                    FilterButton(),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Flexible(
                                      child: SelectableText(
                                          'The current date range is set to:  '),
                                    ),
                                    DatePicker(),
                                  ],
                                ),
                              ],
                            ),
                          )));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: Obx(
          () => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: (() async {
                  filterController.resetFilters();
                }),
                tooltip: 'Reset Filters',
                child: const Icon(Icons.undo),
              ),
              const SizedBox(
                width: 8.0,
              ),
              (appController.chats.isNotEmpty)
                  ? PopupMenuButton(
                      offset: const Offset(0, -112),
                      elevation: 6,
                      initialValue: 0,
                      itemBuilder: (context) {
                        return List.generate(2, (index) {
                          return PopupMenuItem(
                              value: index,
                              child: Text(
                                (index == 0) ? 'Primary' : 'All',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12),
                              ));
                        });
                      },
                      onSelected: ((selection) {
                        appController.exportInteractions(
                            interactionLevel: (selection == 1));
                      }),
                      tooltip: 'Export Current Interactions',
                      child: Material(
                        shape: const CircleBorder(),
                        elevation: 6,
                        child: Container(
                            height: 56,
                            width: 56,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(2, 146, 254, 1),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: const [
                                Icon(Icons.file_download_outlined,
                                    color: Colors.white, size: 32),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: Icon(
                                    Icons.arrow_drop_up,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
