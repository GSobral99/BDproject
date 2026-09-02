# Database - Part 2

## Main File

`estagios_parte2_dump_completo.sql` - full dump exported from phpMyAdmin
(schema + sample data + procedures + functions + triggers + views), ready to
import directly. This is the database that the web prototype in `webapp/`
uses.

```bash
mysql -u root -p -e "CREATE DATABASE estagios_parte2"
mysql -u root -p estagios_parte2 < estagios_parte2_dump_completo.sql
```

## Automation Included in the Dump

| Name | Type | Purpose |
|---|---|---|
| `t1_classificacao_insert` / `t1_classificacao_update` | Trigger | Student's rating of the establishment between 1 and 5 |
| `t2_data_fim_data_inicio_insert` / `t2_data_fim_data_inicio_update` | Trigger | `start_date` cannot be later than `end_date` |
| `p1_registar_estagio` | Procedure | Registers an internship, first validating the existence of the student, trainer, and establishment |
| `p2_next_estagios` | Procedure | Lists internships starting within the next N days |
| `f1_calculo_media_estabelecimentos` | Function | Average of the ratings given by students to an establishment, for a given year |
| `f2_calculo_nota_final` | Function | Weighted final internship grade (configurable weights, only calculates if all components exist) |
| `v1_detalhes_formadores` | View | Number of internships and average grade per trainer vs. global average |
| `v2_media_empresa_curso` | View | Average final grades by company and course |

Queries and views are also isolated in their own files, for anyone who wants to run just the analytical part.

- `consultas/queries.sql` - Q1 to Q6 (the original version in `queries.txt` had a residual syntax error from a PHP `echo`; it's fixed here)
- `consultas/views.sql` - V1 and V2

## ⚠️ Note on Consistency Between Part 1 and Part 2

The schema for this Part 2 (`estagios_parte2`) **is not a direct continuation**
of the Part 1 schema (`SIEstagios`) - table names and some columns were
redesigned (e.g. lowercase, `responsavel` is no longer tied to a composite key
with `estabelecimento`, `ramo` became `ramo_atividade`, `vagas` became
`disponibilidade`, and `classificacao` exists both as a column in `estagio`
and as a table aggregated by year). This reflects the actual process behind
the project - our group rebuilt part of the model while preparing Part 2 - and
is flagged here transparently rather than hidden.

## Sample Data (Seed)

The dump already ships with realistic demo data: ~190 students, several real
companies used as reference, trainers, classes, and internships in different
states (ongoing / completed) - which addresses the request for seed data made
in the first part of this repository.