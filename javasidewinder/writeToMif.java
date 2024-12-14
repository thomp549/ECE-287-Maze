import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Scanner;

public class writeToMif {

    public static void main(String[] args)  throws FileNotFoundException{
        // TODO Auto-generated method stub
        Scanner flipper = new Scanner (new File("mazex119x119.txt"));        
        Scanner reader = new Scanner (new File("mazex119x119.txt"));
        PrintWriter write = new PrintWriter (new File ("maze_background.mif"));
        
        int N = 120 * 120; // the ram/rom depth
        int word_len = 1; // word length used
        write.printf("DEPTH=%d;\n", N);
        write.printf("WIDTH=%d;\n", word_len);
        
        write.printf("ADDRESS_RADIX = UNS;\n");
        write.printf("DATA_RADIX = UNS;\n");
        write.printf("CONTENT\t");
        write.printf("BEGIN\n");
        int i = 0;
        
        while(reader.hasNext()) {
            String line = reader.next();
            for (int j = 0; j < 119; j++) {
                System.out.printf("\t%d\t:\t%s;\n", i, line.substring(j, j + 1));
                write.printf("\t%d\t:\t%s;\n", i, line.substring(j, j + 1));
                i++;
            }
            System.out.printf("\t%d\t:\t%s;\n", i, "1");
            write.printf("\t%d\t:\t%s;\n", i, "1");
            i++;
            
        }
        for (int j = 0; j < 120; j++) {
            System.out.printf("\t%d\t:\t%s;\n", i, "1");
            write.printf("\t%d\t:\t%s;\n", i, "1");
            i++;
        }
        
        write.printf("END;\n");
        write.close();
        reader.close();
    }
   
}
