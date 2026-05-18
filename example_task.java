import java.sql.*;

public class example_task {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;";
        String database = "databaseName=Northwind;";
        String user = "user=sa;";
        String password = "password=1qaz@WSX;";
        String options = "encrypt=true;trustServerCertificate=true;";

        try (Connection conn = DriverManager.getConnection(url + database + user + password + options)) {
            System.out.println("Połączono z bazą.\n");

            // 1. Dodanie nowej pozycji
            System.out.println("--- Test 1: Dodawanie pozycji ---");
            addOrderDetail(conn, 10251, 20, 15.50, 2);

            // 2. Aktualizacja ilości w istniejącej pozycji
            System.out.println("\n--- Test 2: Aktualizacja ilości ---");
            updateOrderDetailQuantity(conn, 10251, 20, 5);

            // 3. Usunięcie wybranej pozycji
            System.out.println("\n--- Test 3: Usuwanie pozycji ---");
            deleteOrderDetail(conn, 10251, 20);

            // 4. Aktualizacja telefonów dla klientów z danego kraju
            System.out.println("\n--- Test 4: Batch update telefonów ---");
            updateCustomerPhonesByCountry(conn, "France");

        } catch (SQLException e) {
            System.out.println("Błąd krytyczny połączenia z bazą!");
            e.printStackTrace();
        }
    }

    // =======================================================================================
    // METODY REALIZUJĄCE ZADANIA
    // =======================================================================================
    public static void addOrderDetail(Connection conn, int orderId, int productId, double unitPrice, int quantity) {
        String sql = "INSERT INTO dbo.[Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount) VALUES (?, ?, ?, ?, 0)";

        try {
            // start transakcji
            conn.setAutoCommit(false);

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, orderId);
                pstmt.setInt(2, productId);
                pstmt.setDouble(3, unitPrice);
                pstmt.setInt(4, quantity);
                pstmt.executeUpdate();
            }

            incrementRequiredDate(conn, orderId);
            logAction(conn, "INSERT", "Dodano produkt " + productId + " do zamówienia " + orderId);

            conn.commit();
            System.out.println("Pomyślnie dodano pozycję do zamówienia.");

        } catch (SQLException e) {
            rollbackTransaction(conn);
            e.printStackTrace();
        } finally {
            restoreAutoCommit(conn);
        }
    }

    public static void updateOrderDetailQuantity(Connection conn, int orderId, int productId, int newQuantity) {
        String sql = "UPDATE [Order Details] SET Quantity = ? WHERE OrderID = ? AND ProductID = ?";

        try {
            conn.setAutoCommit(false);

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, newQuantity);
                pstmt.setInt(2, orderId);
                pstmt.setInt(3, productId);

                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    incrementRequiredDate(conn, orderId);
                    logAction(conn, "UPDATE", "Zmieniono ilość produktu " + productId + " w zamówieniu " + orderId + " na " + newQuantity);
                    conn.commit();
                    System.out.println("Pomyślnie zaktualizowano ilość.");
                } else {
                    System.out.println("Nie znaleziono takiej pozycji do aktualizacji.");
                    conn.rollback();
                }
            }
        } catch (SQLException e) {
            rollbackTransaction(conn);
            e.printStackTrace();
        } finally {
            restoreAutoCommit(conn);
        }
    }

    public static void deleteOrderDetail(Connection conn, int orderId, int productId) {
        String sql = "DELETE FROM [Order Details] WHERE OrderID = ? AND ProductID = ?";

        try {
            conn.setAutoCommit(false);

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, orderId);
                pstmt.setInt(2, productId);

                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    incrementRequiredDate(conn, orderId);
                    logAction(conn, "DELETE", "Usunięto produkt " + productId + " z zamówienia " + orderId);
                    conn.commit();
                    System.out.println("Pomyślnie usunięto pozycję.");
                } else {
                    System.out.println("Nie znaleziono takiej pozycji do usunięcia.");
                    conn.rollback();
                }
            }
        } catch (SQLException e) {
            rollbackTransaction(conn);
            e.printStackTrace();
        } finally {
            restoreAutoCommit(conn);
        }
    }

    public static void updateCustomerPhonesByCountry(Connection conn, String country) {
        String sql = "UPDATE Customers SET Phone = REPLACE(REPLACE(REPLACE(Phone, '5', '3'), '4', '6'), '7', '8') WHERE Country = ?";

        try {
            conn.setAutoCommit(false);

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, country);
                int rows = pstmt.executeUpdate();

                logAction(conn, "BATCH_UPDATE", "Zaktualizowano telefony dla " + rows + " klientów z kraju: " + country);
                conn.commit();
                System.out.println("Zaktualizowano telefony. Liczba zmienionych klientów: " + rows);
            }
        } catch (SQLException e) {
            rollbackTransaction(conn);
            e.printStackTrace();
        } finally {
            restoreAutoCommit(conn);
        }
    }

    // =======================================================================================
    // METODY POMOCNICZE
    // =======================================================================================
    private static void incrementRequiredDate(Connection conn, int orderId) throws SQLException {
        String sql = "UPDATE Orders SET RequiredDate = DATEADD(day, 1, RequiredDate) WHERE OrderID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, orderId);
            pstmt.executeUpdate();
        }
    }

    private static void logAction(Connection conn, String action, String description) throws SQLException {
        String sql = "INSERT INTO Log (Action, Description) VALUES (?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, action);
            pstmt.setString(2, description);
            pstmt.executeUpdate();
        }
    }

    private static void rollbackTransaction(Connection conn) {
        try {
            if (conn != null) {
                System.out.println("Wystąpił błąd. Wycofywanie zmian (Rollback)...");
                conn.rollback();
            }
        } catch (SQLException ex) {
            System.out.println("Błąd podczas wycofywania transakcji!");
            ex.printStackTrace();
        }
    }

    private static void restoreAutoCommit(Connection conn) {
        try {
            if (conn != null) {
                conn.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}
