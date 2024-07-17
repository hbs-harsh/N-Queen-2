import 'package:flutter/material.dart';

void main() {
  runApp(NQueenVisualizer());
}

class NQueenVisualizer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'N-Queen Visualizer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(
          child: ChessBoard(),
        ),
      ),
    );
  }
}

class ChessBoard extends StatefulWidget {
  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  int n = 4;
  late List<List<int>> board;
  bool isRunning = false;
  List<List<int>>? solution;
  int stepDelay = 500; // Delay in milliseconds for each step

  @override
  void initState() {
    super.initState();
    resetBoard();
  }

  void resetBoard() {
    board = List.generate(n, (index) => List.generate(n, (index) => 0));
  }

  Future<void> visualizeNQueen() async {
    setState(() {
      isRunning = true;
      solution = null;
    });

    if (await solveNQueen(0)) {
      setState(() {
        solution = List.from(board);
      });
    }

    setState(() {
      isRunning = false;
    });
  }

  Future<bool> solveNQueen(int col) async {
    if (col >= n) {
      return true;
    }

    for (int i = 0; i < n; i++) {
      if (isSafe(i, col)) {
        setState(() {
          board[i][col] = 1;
        });
        await Future.delayed(Duration(milliseconds: stepDelay));

        if (await solveNQueen(col + 1)) {
          return true;
        }

        setState(() {
          board[i][col] = 0;
        });
        await Future.delayed(Duration(milliseconds: stepDelay));
      }
    }
    return false;
  }

  bool isSafe(int row, int col) {
    for (int i = 0; i < col; i++) {
      if (board[row][i] == 1) {
        return false;
      }
    }

    for (int i = row, j = col; i >= 0 && j >= 0; i--, j--) {
      if (board[i][j] == 1) {
        return false;
      }
    }

    for (int i = row, j = col; j >= 0 && i < n; i++, j--) {
      if (board[i][j] == 1) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < n; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < n; j++)
                ChessBoardSquare(
                  isQueen: board[i][j] == 1,
                  color: (i + j) % 2 == 0
                      ? Color.fromARGB(255, 1, 68, 36)
                      : Color.fromARGB(255, 5, 4, 4),
                ),
            ],
          ),
        SizedBox(height: 20),
        if (isRunning)
          ElevatedButton(
            onPressed: null,
            child: Text('Visualizing...'),
          )
        else ...[
          ElevatedButton(
            onPressed: visualizeNQueen,
            child: Text('Start Visualization'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                resetBoard();
                solution = null;
              });
            },
            child: Text('Reset'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Number of Queens: $n'),
                DropdownButton<int>(
                  value: n,
                  items: [4, 5, 6, 7, 8, 9, 10].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      n = newValue!;
                      resetBoard();
                      solution = null;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Speed (ms per step): $stepDelay'),
                DropdownButton<int>(
                  value: stepDelay,
                  items: [
                    100, 200, 300, 400, 500, 600, 700, 800, 900, 1000
                  ].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      stepDelay = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
        if (solution != null)
          Text(
            'Solution Found!',
            style: TextStyle(
              color: Colors.green, // Set the color to green
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
      ],
    );
  }
}

class ChessBoardSquare extends StatelessWidget {
  final bool isQueen;
  final Color color;

  ChessBoardSquare({required this.isQueen, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      color: color,
      child: Center(
        child: Text(
          isQueen ? '♛' : '',
          style: TextStyle(
            color: isQueen
                ? (color == Colors.white ? Colors.black : Colors.white)
                : color,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
