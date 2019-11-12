import'dart:convert';import'dart:math';import'package:flutter/material.dart';import'package:keyboard_visibility/keyboard_visibility.dart';import'package:shared_preferences/shared_preferences.dart';import'package:uuid/uuid.dart';void main()=>runApp(FastTask());class FastTask extends StatelessWidget{static const TITLE='FastTask';@override Widget build(context){return MaterialApp(title:TITLE,theme:ThemeData(primarySwatch:Colors.indigo),home:TaskPage());}}class TaskPage extends StatefulWidget{final service=TaskService();TaskPage({key}):super(key:key);@override _TaskPageState createState()=>_TaskPageState();}class _TaskPageState extends State<TaskPage>{@override Widget build(context){return Scaffold(appBar:AppBar(title:Text(FastTask.TITLE)),body:FutureBuilder<List<Task>>(future:widget.service.loadTasks(),builder:(context,snapshot){if(snapshot.connectionState==ConnectionState.done){return ListView.builder(itemBuilder:(context,index){Task task=snapshot.data[index];return Hero(tag:task.id,child:Dismissible(key:Key(task.id),onDismissed:(_){snapshot.data.remove(task);widget.service.saveTasks(snapshot.data);},direction:DismissDirection.startToEnd,child:Card(child:Container(height:75.0,padding:EdgeInsets.only(left:12.0,right:4.0),child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:<Widget>[Expanded(child:Text(task.task,style:TextStyle(color:Colors.black,fontSize:18.0),),),Container(decoration:BoxDecoration(color:priorityColor[task.prio],shape:BoxShape.circle),width:50.0,)],),),),),);},itemCount:snapshot.data.length,);}return Container();}),floatingActionButton: FloatingActionButton(child:Icon(Icons.add),onPressed:(){Navigator.push(context,MaterialPageRoute(builder:(context)=>AddPage(taskService: widget.service,)),);},),);}}class AddPage extends StatefulWidget{final TaskService taskService;final taskId=Uuid().v1();AddPage({this.taskService});@override AddPageState createState()=>AddPageState();}class AddPageState extends State<AddPage>{final _editController=TextEditingController();final _keyBoardVisibility=new KeyboardVisibilityNotification();var keyBoardSubscriberId;int colorIndex=Random().nextInt(priorityColor.length);@override void initState(){super.initState();keyBoardSubscriberId=_keyBoardVisibility.addNewListener(onChange:(bool visible){if(!visible&&_editController.text.length>0){widget.taskService.saveTask(Task(id:widget.taskId,task:_editController.text,prio:colorIndex));Navigator.pop(context);}},);}@override void dispose(){_keyBoardVisibility.removeListener(keyBoardSubscriberId);super.dispose();}@override Widget build(context){return Scaffold(appBar:AppBar(title:Text("Add task"),),body:Column(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:<Widget>[GestureDetector(onTap:(){setState((){colorIndex<priorityColor.length-1?colorIndex++:colorIndex=0;});},child:Container(height:150.0,child:Hero(tag:widget.taskId,child:Card(color:priorityColor[colorIndex],child:Column(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:<Widget>[TextField(style:TextStyle(fontSize:32.0,color:Colors.white),autofocus:true,textAlign:TextAlign.center,maxLength:15,controller:_editController,decoration: InputDecoration.collapsed(hintText:'Tap to change priority',enabled:false),),],),),),),),],),);}}final priorityColor=[Color(0xFFFF645C),Color(0xFFFFF36E),Color(0xFF95FF8A)];class Task{final String id;final String task;final int prio;Task({this.id,this.task,this.prio});Task.fromJson(Map<String,dynamic>json):id=json['id'],task=json['task'],prio=json['prio'];Map<String,dynamic>toJson()=>{'id':id,'task':task,'prio':prio};}class TaskService{final taskPrefs="TASKS";Future<List<Task>>loadTasks()async{try{List<String>tasks=(await SharedPreferences.getInstance()).getStringList(taskPrefs);return tasks.map((t)=>Task.fromJson(json.decode(t))).toList();}catch(_){return[Task(id: '1',task: 'Add task',prio: 0),];}}saveTasks(List<Task> tasks) async {List<String> jsonTasks = tasks.map((t) => json.encode(t.toJson())).toList();(await SharedPreferences.getInstance()).setStringList(taskPrefs, jsonTasks);}saveTask(Task task)async{List<Task>openTasks=await loadTasks();openTasks.add(task);saveTasks(openTasks);}}