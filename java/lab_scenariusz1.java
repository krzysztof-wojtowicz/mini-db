import java.sql.*;
public class lab_scenariusz1 {
    public static void Scenariusz1() {
        // dane połączenia z bazą
        String url = "jdbc:sqlserver://localhost:1433;";
        String database = "databaseName=Northwind;";
        String user = "user=sa;";
        String password = "password=1qaz@WSX;";
        String options = "encrypt=true;trustServerCertificate=true;";

        // blok try-catch-with-resources
        try (Connection conn = DriverManager.getConnection(url + database + user + password + options);
             Statement stmt = conn.createStatement();) {

            // wszyscy pracownicy
            System.out.println("\nWszyscy pracownicy:");
            String sql1 = "SELECT E.FirstName, E.LastName FROM dbo.Employees E " +
                    "GROUP BY E.FirstName, E.LastName ";
            ResultSet rs1 = stmt.executeQuery(sql1);

            int j = 1;
            while (rs1.next()) {
                System.out.println("Pracownik " + j++ + ": " + rs1.getString("FirstName") + " " + rs1.getString("LastName"));
            }

            // pracownicy, którzy obsługiwali zamówienia dla klientów z Francji
            System.out.println("\nPracownicy, którzy obsługiwali zamówienia klientów z Francji:");
            String sql2 = "SELECT E.FirstName, E.LastName FROM Employees E " +
                    "JOIN dbo.Orders O on E.EmployeeID = O.EmployeeID " +
                    "JOIN dbo.Customers C on O.CustomerID = C.CustomerID " +
                    "WHERE C.Country = 'France' " +
                    "GROUP BY  E.FirstName, E.LastName ";
            ResultSet rs2 = stmt.executeQuery(sql2);

            int i = 0;
            while (rs2.next()) {
                System.out.println("Pracownik " + i++ + ": " + rs2.getString("FirstName") + " " + rs2.getString("LastName"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
