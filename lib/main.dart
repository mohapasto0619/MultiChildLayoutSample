import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Child Layout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Cars'),
    );
  }
}

@riverpod
class IsMapActive extends _$IsMapActive {
  @override
  bool build() {
    return false;
  }

  void set() {
    state = !state;
  }

  void reset() {
    state = false;
  }
}

@riverpod
class IsAlarmActive extends _$IsAlarmActive {
  @override
  bool build() {
    return false;
  }

  void set() {
    state = !state;
  }

  void reset() {
    state = false;
  }
}

@riverpod
class IsAddActive extends _$IsAddActive {
  @override
  bool build() {
    return false;
  }

  void set() {
    state = !state;
  }

  void reset() {
    state = false;
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() {
      // just print the current value
      debugPrint(_animationController.value.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMapActive = ref.watch(isMapActiveProvider);
    final isAlarmActive = ref.watch(isAlarmActiveProvider);
    final isAddActive = ref.watch(isAddActiveProvider);

    ref.listen(isAddActiveProvider, (_, next) {
      if (next) {
        ref.read(isAlarmActiveProvider.notifier).reset();
        ref.read(isMapActiveProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder:
            (context, child) => CustomMultiChildLayout(
              delegate: MyDelegate(
                textDirection: TextDirection.ltr,
                animationController: _animationController,
              ),
              children: [
                LayoutId(id: 'car_list', child: CarListWidget()),
                LayoutId(
                  id: 'right_down_floating_buttons',
                  child: RightDownFloatingButtonsWidget(
                    onAddPressed:
                        () => ref.read(isAddActiveProvider.notifier).set(),
                    onRefreshPressed: () => print("Refresh pressed"),
                    onAlarmPressed:
                        () => ref.read(isAlarmActiveProvider.notifier).set(),
                  ),
                ),
                LayoutId(
                  id: 'map_floating_button',
                  child: MapButtonWidget(
                    onPressed:
                        () => ref.read(isMapActiveProvider.notifier).set(),
                  ),
                ),
                if (isMapActive)
                  LayoutId(
                    id: 'map',
                    child: MapWidget(
                      onPressed:
                          () => ref.read(isMapActiveProvider.notifier).reset(),
                    ),
                  ),
                if (isAlarmActive)
                  LayoutId(
                    id: 'alarm',
                    child: AlarmWidget(
                      onPressed:
                          () =>
                              ref.read(isAlarmActiveProvider.notifier).reset(),
                    ),
                  ),
                if (isAddActive)
                  LayoutId(
                    id: 'add',
                    child: AddWidget(
                      onPressed:
                          () => ref.read(isAddActiveProvider.notifier).reset(),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}

class MyDelegate extends MultiChildLayoutDelegate {
  MyDelegate({
    super.relayout,
    required this.textDirection,
    required this.animationController,
  });

  final TextDirection textDirection;
  final AnimationController animationController;

  @override
  void performLayout(Size size) {
    if (hasChild('car_list')) {
      layoutChild('car_list', BoxConstraints.loose(size));
      positionChild('car_list', Offset(0.0, 0.0));
    }

    final layoutWidth = size.width;
    final layoutHeight = size.height;
    final defaultHorizontalPadding = size.width / 30;
    final defaultVerticalPadding = size.height / 30;

    Size rightDownFloatingButtonsSize = Size.zero;

    if (hasChild('right_down_floating_buttons')) {
      rightDownFloatingButtonsSize = layoutChild(
        'right_down_floating_buttons',
        BoxConstraints.tightFor(height: size.height / 2),
      );
      positionChild(
        'right_down_floating_buttons',
        Offset(
          size.width -
              (rightDownFloatingButtonsSize.width + defaultHorizontalPadding),
          size.height -
              (rightDownFloatingButtonsSize.height + defaultVerticalPadding),
        ),
      );
    }

    Size mapFloatingButtonSize = Size.zero;

    if (hasChild('map_floating_button')) {
      mapFloatingButtonSize = layoutChild(
        'map_floating_button',
        BoxConstraints.loose(size),
      );
      positionChild(
        'map_floating_button',
        Offset(
          layoutWidth -
              (mapFloatingButtonSize.width + defaultHorizontalPadding),
          defaultVerticalPadding,
        ),
      );
    }

    Size mapSize = Size.zero;

    if (hasChild('map')) {
      mapSize = layoutChild(
        'map',
        BoxConstraints.expand(
          width: layoutWidth - (defaultHorizontalPadding) * 2,
          height: layoutHeight / 2.5,
        ),
      );
      positionChild(
        'map',
        Offset((layoutWidth - mapSize.width) / 2, defaultVerticalPadding),
      );
    }

    Size alarmSize = Size.zero;
    Animation<double> alarmPositionXAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(animationController);
    Animation<double> alarmPositionYAnimation = Tween<double>(
      begin: layoutHeight / 2,
      end: layoutHeight / 2 - defaultVerticalPadding * 2,
    ).animate(animationController);

    if (hasChild('alarm')) {
      alarmSize = layoutChild(
        'alarm',
        BoxConstraints.expand(
          width: layoutWidth - (defaultHorizontalPadding) * 2,
          height: layoutHeight / 4,
        ),
      );
      positionChild(
        'alarm',
        Offset(
          (layoutWidth - alarmSize.width) / 2,
          layoutHeight / 2 - defaultVerticalPadding,
        ),
      );
    }

    Size addSize = Size.zero;

    if (hasChild('add')) {
      addSize = layoutChild(
        'add',
        BoxConstraints.expand(
          width: layoutWidth - (defaultHorizontalPadding) * 2,
          height: layoutHeight - (defaultVerticalPadding) * 2,
        ),
      );
      positionChild(
        'add',
        Offset((layoutWidth - addSize.width) / 2, defaultVerticalPadding),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MyDelegate oldDelegate) {
    return oldDelegate.textDirection != textDirection;
  }
}

class Car {
  final String brand;
  final String model;
  final int year;

  Car({required this.brand, required this.model, required this.year});
}

final List<Car> fakeCars = [
  Car(brand: "Toyota", model: "Corolla", year: 2020),
  Car(brand: "Honda", model: "Civic", year: 2019),
  Car(brand: "Ford", model: "Mustang", year: 2021),
  Car(brand: "Chevrolet", model: "Camaro", year: 2018),
  Car(brand: "Tesla", model: "Model S", year: 2022),
  Car(brand: "BMW", model: "M3", year: 2020),
  Car(brand: "Mercedes", model: "C-Class", year: 2021),
  Car(brand: "Audi", model: "A4", year: 2019),
  Car(brand: "Volkswagen", model: "Golf", year: 2018),
  Car(brand: "Nissan", model: "Altima", year: 2022),
  Car(brand: "Subaru", model: "Impreza", year: 2021),
  Car(brand: "Mazda", model: "CX-5", year: 2020),
  Car(brand: "Lexus", model: "RX", year: 2019),
  Car(brand: "Hyundai", model: "Elantra", year: 2022),
  Car(brand: "Kia", model: "Sorento", year: 2021),
  Car(brand: "Porsche", model: "911", year: 2023),
  Car(brand: "Ferrari", model: "488", year: 2022),
  Car(brand: "Lamborghini", model: "Huracan", year: 2021),
  Car(brand: "Jaguar", model: "F-Type", year: 2020),
  Car(brand: "Land Rover", model: "Range Rover", year: 2019),
];

class CarListWidget extends StatelessWidget {
  const CarListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: fakeCars.length,
        itemBuilder: (context, index) {
          final car = fakeCars[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.directions_car,
                color: Colors.deepPurpleAccent,
              ),
              title: Text(
                "${car.brand} ${car.model}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Année: ${car.year}"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text("Voir détails"),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RightDownFloatingButtonsWidget extends StatelessWidget {
  const RightDownFloatingButtonsWidget({
    super.key,
    required this.onAddPressed,
    required this.onRefreshPressed,
    required this.onAlarmPressed,
  });

  final VoidCallback onAddPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback onAlarmPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: onAlarmPressed,
              heroTag: "btn3",
              child: Icon(Icons.add_alarm_rounded),
            ),
            Column(
              children: [
                FloatingActionButton(
                  onPressed: onRefreshPressed,
                  heroTag: "btn2",
                  child: Icon(Icons.refresh),
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: onAddPressed,
                  heroTag: "btn1",
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MapButtonWidget extends StatelessWidget {
  const MapButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FloatingActionButton(
          onPressed: onPressed,
          heroTag: "btn3",
          child: Icon(Icons.map),
        ),
      ),
    );
  }
}

class MapWidget extends StatelessWidget {
  const MapWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Map",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.white.withAlpha(180),
              ),
            ),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.green.withAlpha(150)),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmWidget extends StatelessWidget {
  const AlarmWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Alarm",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.white.withAlpha(180),
              ),
            ),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.red.withAlpha(150)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddWidget extends StatelessWidget {
  const AddWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Add",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.white.withAlpha(180),
              ),
            ),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.blue.withAlpha(150)),
            ),
          ),
        ],
      ),
    );
  }
}
