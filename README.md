# Torkis

A modern and comprehensive information system for car repair shops built with the **Flutter** framework. 
The application digitalizes the entire workflow of a repair shop - from vehicle intake, mechanics' work tracking, and inventory management, to automated PDF invoice generation and customer communication.

---

## Main Features

* **Job Management**: Vehicle records (License plates, VIN), service intake, customer requests, and defect photo documentation.
* **Role-Based Access Control**: Specific access rights for *Owner/Admin*, *Technician*, and *Mechanic* roles.
* **Inventory Management**: 
  * Parts tracking and low stock alerts.
  * **Barcode and QR code scanning** for fast stock intake and dispatch.
  * Over-the-counter sales with a shopping cart and direct receipt generation.
* **Invoicing and PDF Documents**: 
  * Automated generation of service protocols, price quotes, and final PDF invoices.
  * Chronological and secure invoice numbering using transactional counters.
  * Document cancellation feature with automatic return of parts to the inventory.
* **Email Communication**: Sending PDF quotes and invoices directly from the application to the customer's email.
* **User Interface**: Fully responsive design with **Dark / Light mode** support.

---

## Technologies Used

* **Frontend:** [Flutter](https://flutter.dev/) & Dart
* **Backend & Database:** [Firebase](https://firebase.google.com/)
  * *Authentication* (User management)
  * *Cloud Firestore* (Real-time NoSQL database)
  * *Firebase Storage* (Photo and PDF document storage)
* **Key Packages:**
  * `printing` and `pdf` (Document creation and printing)
  * `flutter_barcode_scanner` (Camera barcode scanner)
  * `image_picker` (Photo documentation capturing)

---

## How to run locally

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/JanSvihalek/Torkis.git](https://github.com/JanSvihalek/Torkis.git)
