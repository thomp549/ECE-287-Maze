/*

import java.util.Random;

public class SidewinderMaze {
    // Constants for directions
    private static final int N = 1;
    private static final int S = 2;
    private static final int E = 4;
    private static final int W = 8;

    public static void main(String[] args) {
        // 1. Parse command-line parameters
        int width = (args.length > 0) ? Integer.parseInt(args[0]) : 120;
        int height = (args.length > 1) ? Integer.parseInt(args[1]) : width;
        int weight = (args.length > 2) ? Integer.parseInt(args[2]) : 2;
        int seed = (args.length > 3) ? Integer.parseInt(args[3]) : new Random().nextInt();

        Random random = new Random(seed);

        // 2. Initialize the grid
        int[][] grid = new int[height][width];

        // 3. Generate the maze using the Sidewinder algorithm
        System.out.print("\033[2J"); // Clear the screen
        for (int y = 0; y < height; y++) {
            int runStart = 0;
            for (int x = 0; x < width; x++) {
                //displayMaze(grid); // Show the maze in progress
                System.out.println("loading");
                try {
                    Thread.sleep(20); // Pause for 20ms for visualization
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }

                boolean closeRun = (y > 0) && (x + 1 == width || random.nextInt(weight) == 0);

                if (closeRun) {
                    int cell = runStart + random.nextInt(x - runStart + 1);
                    grid[y][cell] |= N;
                    grid[y - 1][cell] |= S;
                    runStart = x + 1;
                } else if (x + 1 < width) {
                    grid[y][x] |= E;
                    grid[y][x + 1] |= W;
                }
            }
        }

        // Final display of the completed maze
        displayMaze(grid);

        // 4. Show the parameters used to generate the maze
        System.out.printf("java SidewinderMaze %d %d %d %d%n", width, height, weight, seed);
    }

    // Method to display the maze as ASCII art
    private static void displayMaze(int[][] grid) {
        System.out.print("\033[H"); // Move to the top-left of the console
        int height = grid.length;
        int width = grid[0].length;

        // Print the top border
        System.out.print("0");
        for (int i = 0; i < width * 2 - 1; i++) {
            System.out.print("1");
        }
        System.out.println();

        // Print each row of the maze
        for (int y = 0; y < height; y++) {
            System.out.print("1"); // Left border
            for (int x = 0; x < width; x++) {
                int cell = grid[y][x];
                boolean southWall = (cell & S) == 0;
                boolean eastWall = (cell & E) == 0;

                // Draw the bottom edge of the cell
                System.out.print(southWall ? "1" : "0");

                // Draw the right edge of the cell
                if (eastWall) {
                    System.out.print("1");
                } else {
                    System.out.print((cell & S) != 0 ? "0" : "1");
                }
            }
            System.out.println();
        }
    }
}*/

import java.util.Random;

public class SidewinderMaze {
    // Constants for directions
    private static final int N = 1;
    private static final int S = 2;
    private static final int E = 4;
    private static final int W = 8;

    public static void main(String[] args) {
        // 1. Parse command-line parameters
        int width = (args.length > 0) ? Integer.parseInt(args[0]) : 59;
        int height = (args.length > 1) ? Integer.parseInt(args[1]) : width;
        int weight = (args.length > 2) ? Integer.parseInt(args[2]) : 2;
        int seed = (args.length > 3) ? Integer.parseInt(args[3]) : new Random().nextInt();

        Random random = new Random(seed);

        // 2. Initialize the grid
        int[][] grid = new int[height][width];

        // 3. Generate the maze using the Sidewinder algorithm
        System.out.print("\033[2J"); // Clear the screen
        for (int y = 0; y < height; y++) {
            int runStart = 0;
            for (int x = 0; x < width; x++) {
                //displayMaze(grid); // Show the maze in progress
                System.out.println("loading");
               // try {
               //     Thread.sleep(20); // Pause for 20ms for visualization
               // } catch (InterruptedException e) {
               //     Thread.currentThread().interrupt();
               // }

                boolean closeRun = (y > 0) && (x + 1 == width || random.nextInt(weight) == 0);

                if (closeRun) {
                    int cell = runStart + random.nextInt(x - runStart + 1);
                    grid[y][cell] |= N;
                    grid[y - 1][cell] |= S;
                    runStart = x + 1;
                } else if (x + 1 < width) {
                    grid[y][x] |= E;
                    grid[y][x + 1] |= W;
                }
            }
        }

        // Final display of the completed maze
        displayMaze(grid);

        // 4. Show the parameters used to generate the maze
        System.out.printf("java SidewinderMaze %d %d %d %d%n", width, height, weight, seed);
    }

    private static void displayMaze(int[][] grid) {
        int height = grid.length;
        int width = grid[0].length;

        // Dimensions for walls and paths
        int rows = height * 2 + 1;
        int cols = width * 2 + 1;
        int[][] maze = new int[rows][cols];

        // Initialize everything as walls
        for (int[] row : maze) {
            java.util.Arrays.fill(row, 1);
        }

        // Translate the grid into paths and walls
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int cell = grid[y][x];
                int row = y * 2 + 1;
                int col = x * 2 + 1;

                maze[row][col] = 0; // Mark the cell itself as a path
                if ((cell & N) != 0) maze[row - 1][col] = 0; // North path
                if ((cell & S) != 0) maze[row + 1][col] = 0; // South path
                if ((cell & W) != 0) maze[row][col - 1] = 0; // West path
                if ((cell & E) != 0) maze[row][col + 1] = 0; // East path
            }
        }

        // Print the maze
        for (int[] row : maze) {
            for (int cell : row) {
                System.out.print(cell);
            }
            System.out.println();
        }
    }
    
    
}

