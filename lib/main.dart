// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

/*
! RIVERPOD
-> In Riverpod we create it as a globalvariable
   ie: final counterProvider = StateProvider((ref) => 0);
   can be: Provider, StateProvider, FutureProvider, StreamProvider, NotifierProvider, StateNotifierProvider, ChangeNotifierProvider	
   link: https://riverpod.dev/docs/concepts/providers

-> Then we wrap the whole app in ProviderScope. No need for any MultiProvider like in Providers package.
   ie: void main() {runApp (ProviderScope(child: MyApp()));}

-> We extend the the Widget/Page (stateful or stateless) where we want to implement Riverpod with ConsumerWidget
   ie: class CounterPage extends ConsumerWidget {}

-> If we dont want to preserve state, means when we go out of the page the counter must return to initial state we will use 
   autoDispose. This is best when there is heavy computing in a page, and when we return back or chnge page we dont want to store 
   the state this is very benificial. Makes app performance better (languageapp)
   ie: final counterProvider = StateProvider.autoDispose((ref) => 0);

-> The ConsumerWidget{} will give you a WidgetRef ref. This ref can be used to call functions like ref.read(), ref.listen(), 
   ref.watch(), ref.invalidate()
   Widget build(BuildContext context, WidgetRef ref) {}

-> Different providers can share data among each other. Like if we create a globalProvider1 and globalProvider2. And  access data 
   of globalProvider1 inside globalProvider2. 
   - Done in example below in websocketClientProvider and counterProvider. We used data of one provider inside another using ref.watch()


! Functions
1) ref.read(): basically to update some data. To write to the Provider. This will write to the globalVariable
   ie: ref.read(counterProvider.notifier).state++;

2) ref.watch(): to watch if the globalVariable is changed. This will rebuild the widget everytime the variable changes
   ie: final int counter = ref.watch(counterProvider);

3) ref.listen(): this is like a mix of ref.watch() and WidgetsBinding.instance!.addPostFrameCallback((_) {}). It will watch the 
   variable like ref.watch() but you can store Widgets inside. That will execute after the screen has completed building. Same as
   WidgetsBinding.instance!.addPostFrameCallback
   - Takes in a callback. Has 2 things. previous state and next state. 
     Previous state eg: the old counter value. like: 0
     New state eg: the new counter value. like: 1

4) ref.invalidate(): will reset the globalVariable to initial state. There is also a ref.reset() but ref.invalidate() works better


NOTE: The below code doesnt work. It is only for reference purposes only
Problem: ProviderScope not working 

Link: Reso Coder: Riverpod 2.0 – Complete Guide (Flutter Tutorial)
  https://youtu.be/Zp7VKVhirmw?si=AsDW3aRKgCp1rWkp
  link2(notes): https://resocoder.com/2022/04/22/riverpod-2-0-complete-guide-flutter-tutorial/

*/




final counterProvider = StateProvider((ref) => 0);


// Creating 2 globalProviers. And using data of one provider inside another using ref.watch()
final websocketClientProvider = Provider<WebsocketClient>(
  (ref) {
    return FakeWebsocketClient();
  },
);

final counterProvider = StreamProvider<int>((ref) {
  final wsClient = ref.watch(websocketClientProvider);
  return wsClient.getCounterStream();
});




void main() {
 runApp(
   ProviderScope(
     child: const MyApp(),
   ),
 );
}

class MyApp extends StatelessWidget {
 const MyApp({Key? key}) : super(key: key);
 
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Counter App',
     home: const HomePage(),
   );
 }
}

class HomePage extends StatelessWidget {
 const HomePage({Key? key}) : super(key: key);
 
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Home'),
     ),
     body: Center(
       child: ElevatedButton(
         child: const Text('Go to Counter Page'),
         onPressed: () {
           Navigator.of(context).push(
             MaterialPageRoute(
               builder: ((context) => const CounterPage()),
             ),
           );
         },
       ),
     ),
   );
 }
}

class CounterPage extends ConsumerWidget {
 const CounterPage({Key? key}) : super(key: key);
 
 @override
 Widget build(BuildContext context, WidgetRef ref) {
 final int counter = ref.watch(counterProvider);

    ref.listen<int>(
      counterProvider,
      (previous, next) {
        if (next >= 5) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Warning'),
                content:
                    Text('Counter dangerously high. Consider resetting it.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  )
                ],
              );
            },
          );
        }
      },
    );
 
   return Scaffold(
     appBar: AppBar(
       title: const Text('Counter'),
     ),
     body: Center(
       child: Text(
         counter.toString(),
         style: Theme.of(context).textTheme.displayMedium,
       ),
     ),
     floatingActionButton: FloatingActionButton(
       child: const Icon(Icons.add),
       onPressed: () {
         ref.read(counterProvider.notifier).state++;
       },
     ),
   );
 }
}