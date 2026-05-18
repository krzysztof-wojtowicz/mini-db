import java.sql.*;

public class lab_scenariusz2 {
    public static void Scenariusz2() {
        // dane połączenia z bazą
        String url = "jdbc:sqlserver://localhost:1433;";
        String database = "databaseName=Northwind;";
        String user = "user=sa;";
        String password = "password=1qaz@WSX;";
        String options = "encrypt=true;trustServerCertificate=true;";

        // blok try-catch-with-resources
        try (Connection conn = DriverManager.getConnection(url + database + user + password + options)) {

            // wyłączamy auto commit
            conn.setAutoCommit(false);

            try {
                // ==========================================
                // TRANSAKCJA 1: Pracownicy
                // ==========================================
                System.out.println("\nTRANSAKCJA 1...");
                try (Statement stmt = conn.createStatement()) {
                    // wstawienie danych dwóch nowych pracowników
                    stmt.executeUpdate("INSERT INTO Employees (FirstName, LastName) VALUES ('Jan', 'Kowalski')");
                    stmt.executeUpdate("INSERT INTO Employees (FirstName, LastName) VALUES ('Anna', 'Nowak')");

                    // zmiana nazwiska jednego z istniejących pracowników
                    stmt.executeUpdate("UPDATE Employees SET LastName = 'Zieliński' WHERE EmployeeID = 1");
                }

                // zatwierdzenie pierwszej transakcji
                conn.commit();
                System.out.println("Transakcja 1 zatwierdzona.");

                // ==========================================
                // TRANSAKCJA 2: 10 zamówień w pętli
                // ==========================================
                System.out.println("TRANSAKCJA 2...");

                // szablon zapytania
                String sqlInsertOrder = "INSERT INTO Orders (CustomerID, EmployeeID) VALUES (?, ?)";

                // używamy preparedStatement
                try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertOrder)) {
                    // dodajemy 10 nowych zamówień do bazy
                    for (int i = 0; i < 10; i++) {
                        pstmt.setString(1, "VINET");
                        pstmt.setInt(2, 1);

                        // wstawiamy rekord
                        pstmt.executeUpdate();
                    }
                }

                // zatwierdzenie drugiej transakcji
                conn.commit();
                System.out.println("Transakcja 2 zatwierdzona.");
            } catch (SQLException ex) {
                // w wypadku błędu robimy rollback zmian
                System.out.println("Wystąpił błąd! Wycofuję transakcję (Rollback).");
                conn.rollback();
                ex.printStackTrace();
            } finally {
                // przywracamy domyślny stan na koniec
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
