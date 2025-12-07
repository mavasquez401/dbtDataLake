"""
Generate architecture diagrams for the data lake platform.
Creates visual representations of the system architecture.
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.analytics import Glue
from diagrams.aws.storage import S3
from diagrams.custom import Custom
from diagrams.onprem.analytics import Dbt
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.database import PostgreSQL
from diagrams.programming.language import Python


def generate_architecture_diagram():
    """Generate main architecture diagram."""
    with Diagram(
        "Institutional Data Lake Architecture",
        filename="docs/architecture_diagram",
        show=False,
        direction="LR",
    ):
        # Data Sources
        with Cluster("Data Producers"):
            finance = S3("Finance\nData")
            operations = S3("Operations\nData")
            crm = S3("CRM\nData")

        # S3 Data Lake
        with Cluster("AWS Data Lake"):
            s3_bucket = S3("S3 Bucket\nData Lake")
            glue_catalog = Glue("Glue Catalog\n& Crawlers")

        # Snowflake
        with Cluster("Snowflake Data Warehouse"):
            with Cluster("Data Vault 2.0"):
                stage = PostgreSQL("STAGE\nHubs/Links/Sats")

            with Cluster("Medallion Architecture"):
                bronze = PostgreSQL("BRONZE\nRaw Data")
                silver = PostgreSQL("SILVER\nCleansed")
                gold = PostgreSQL("GOLD\nBusiness Ready")

        # dbt Transformations
        dbt_transform = Dbt("dbt\nTransformations")

        # Data Quality
        quality = Python("Great\nExpectations")

        # CI/CD
        cicd = GithubActions("GitHub\nActions")

        # Data Flow
        finance >> s3_bucket
        operations >> s3_bucket
        crm >> s3_bucket

        s3_bucket >> glue_catalog
        glue_catalog >> stage

        stage >> Edge(label="dbt") >> bronze
        bronze >> Edge(label="dbt") >> silver
        silver >> Edge(label="dbt") >> gold

        dbt_transform >> Edge(style="dashed") >> bronze
        dbt_transform >> Edge(style="dashed") >> silver
        dbt_transform >> Edge(style="dashed") >> gold

        quality >> Edge(label="validate", style="dotted") >> bronze
        quality >> Edge(label="validate", style="dotted") >> silver
        quality >> Edge(label="validate", style="dotted") >> gold

        cicd >> Edge(label="deploy") >> dbt_transform
        cicd >> Edge(label="test") >> quality


def generate_data_flow_diagram():
    """Generate detailed data flow diagram."""
    with Diagram(
        "Data Flow Pipeline",
        filename="docs/data_flow_diagram",
        show=False,
        direction="TB",
    ):
        # Source Systems
        with Cluster("Source Systems"):
            sources = [S3("Finance"), S3("Operations"), S3("CRM")]

        # Ingestion
        with Cluster("Ingestion Layer"):
            s3 = S3("S3 Data Lake")
            glue = Glue("Glue Crawlers")

        # Data Vault
        with Cluster("Data Vault Layer"):
            hubs = PostgreSQL("Hubs")
            links = PostgreSQL("Links")
            sats = PostgreSQL("Satellites")

        # Bronze Layer
        with Cluster("Bronze Layer"):
            bronze_tables = [
                PostgreSQL("Customers"),
                PostgreSQL("Accounts"),
                PostgreSQL("Transactions"),
                PostgreSQL("Orders"),
            ]

        # Silver Layer
        with Cluster("Silver Layer"):
            silver_tables = [
                PostgreSQL("Customers\nCleansed"),
                PostgreSQL("Transactions\nCleansed"),
                PostgreSQL("Orders\nCleansed"),
            ]

        # Gold Layer
        with Cluster("Gold Layer"):
            gold_tables = [
                PostgreSQL("Customer\nSummary"),
                PostgreSQL("Transaction\nSummary"),
                PostgreSQL("Order\nMetrics"),
                PostgreSQL("Cross-Domain\nAnalytics"),
            ]

        # Data Quality
        quality = Python("Data Quality\nValidation")

        # Flow
        for source in sources:
            source >> s3

        s3 >> glue
        glue >> hubs
        glue >> links
        glue >> sats

        hubs >> bronze_tables[0]
        links >> bronze_tables[1]
        sats >> bronze_tables[2]

        for bronze in bronze_tables:
            bronze >> silver_tables[0]

        for silver in silver_tables:
            silver >> gold_tables[0]

        quality >> Edge(style="dotted") >> bronze_tables[0]
        quality >> Edge(style="dotted") >> silver_tables[0]
        quality >> Edge(style="dotted") >> gold_tables[0]


def main():
    """Generate all diagrams."""
    print("Generating architecture diagrams...")
    print("  - Main architecture diagram")
    generate_architecture_diagram()
    print("  ✓ Created: docs/architecture_diagram.png")

    print("  - Data flow diagram")
    generate_data_flow_diagram()
    print("  ✓ Created: docs/data_flow_diagram.png")

    print("\nDiagrams generated successfully!")


if __name__ == "__main__":
    main()

