# Web Prototype - SIEstágios (Part 2)

Functional prototype in PHP + MySQL/MariaDB with three portals (Admin, Trainer,
Student), built on top of the schema in `database/parte2/estagios_parte2_dump_completo.sql`.

## Project Demo

<video src="docs/Demonstracaoprototipowebg41.mp4" width="100%" controls>
</video>

## How to Run Locally (XAMPP / WAMP / MAMP)

1. Copy this folder (`webapp/`) into your server's public folder (e.g. `htdocs/siestagios/` on XAMPP).
2. Create a database named `estagios_parte2` in phpMyAdmin.
3. Import `database/parte2/estagios_parte2_dump_completo.sql` into that database (contains tables, sample data, procedures, functions, triggers, and views).
4. Confirm the credentials in `db.php` (default: host `localhost`, user `root`, no password - the XAMPP default).
5. Open `http://localhost/siestagios/Home.html` in your browser.

> ⚠️ `db.php` ships with local development credentials (root, no password), exactly as used during the project's development. Never use plaintext credentials in a versioned `.php` file in production - this is acceptable here only because it's an academic project running in a local environment.

> `Home.html` references `logo_iscte.png`, which is not included in this repository. Add your own logo with that filename in the same folder, or remove the corresponding `<img>` tag.

## Test Accounts

| Role | Login | Password |
|---|---|---|
| Student | `joao.silva` | `pass123` |
| Trainer | `ana.mendes` | `pass123` |
| Admin | `helena.alves` | `pass123` |

(More sample accounts in `database/parte2/estagios_parte2_dump_completo.sql`, `utilizador` table.)

## Portal Structure

- **`index.php`** - Login (redirects based on the user's `tipo`).
- **`Home.html`** - Project presentation page (splash screen before login).
- **Student Portal:** `empresas.php` (browses and filters companies), `meus_estagios.php` (own internship details, supervisor, trainer, transport options).
- **Trainer Portal:** `atribuir_notas.php` (submits the 4 grade components; the final grade is calculated by the SQL function `f2_calculo_nota_final`).
- **Admin Portal:** `dashboard_admin.php` (menu), `gerir_alunos.php` / `registar_aluno.php` / `editar_aluno.php` (student CRUD), `gerir_estagios.php` / `registar_estagio.php` / `editar_estagio.php` (internship CRUD, uses the `p1_registar_estagio` stored procedure), `estatisticas.php` (renders the report's Q1-Q6 queries and V1/V2 views as HTML tables).

## Technical Highlights

- All queries use **prepared statements** (`mysqli_prepare` + `bind_param`), including a dynamic `IN (...)` for batch deletion (`gerir_alunos.php`, `gerir_estagios.php`).
- Registering and editing internships delegate the existence checks for student/trainer/establishment to the `p1_registar_estagio` stored procedure, instead of duplicating that logic in PHP.
- Trigger and constraint errors (invalid dates, duplicates) are caught in PHP with `try/catch` and translated into friendly messages, instead of showing the raw MySQL error to the user (`registar_estagio.php`).
- Internships with a filled-in `nota_final` are treated as "completed" and are protected from editing/deletion directly in the interface.

## Known Limitations (Acknowledged in the Report)

- Trainers cannot be created through the interface - SQL only.
- No validation that internship dates fall within the academic calendar.
- A few isolated fatal errors identified late in development weren't fixed in time (see report, section 4.4).