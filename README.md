# Spotify-Data-Analysis-SQL
Project Overview
This project analyzes personal Spotify streaming history data to uncover music listening patterns, preferences, and behaviors. Using SQL and exploratory data analysis (EDA), it answers questions like:

Who are my most-streamed artists and songs?

When do I listen to music the most?

How often do I skip tracks or explore new artists?

The analysis provides actionable insights into habits like late-night listening, weekend trends, and loyalty to favorite artists vs. discovery of new ones.

Key Features
🔍 Exploratory Data Analysis (EDA):

Cleaned and validated raw data (handling nulls, type conversions, etc.).

Analyzed timestamp patterns (hourly, weekly, and yearly trends).

Identified skipped tracks and calculated skip rates for "favorite" songs.

📊 Key Insights:

Top Artists & Songs: Discovered most-streamed tracks and artists over 2023 and 2024.

Peak Listening Hours: Found 8 PM as the most active time for music streaming.

Discovery vs. Loyalty: Quantified how often new artists are explored vs. repeated listens.

Skipping Behavior: Identified tracks skipped most frequently and average playtime before skips.

Technologies Used
SQL: For data cleaning, transformation, and analysis.

MySQL: Database management and query execution.

Data Visualization: Insights visualized through charts (e.g., peak listening hours, skip rates).

├── Data/                   # Raw and cleaned datasets (CSV)  
├── Queries/                # SQL scripts for analysis  
│   ├── top_artists.sql  
│   ├── skipping_behavior.sql  
│   └── time_analysis.sql  
├── Documentation/          # Project report and visuals  
├── README.md               # Project overview and setup guide  
└── .gitignore  


🌟 Why This Project?

Perfect for music enthusiasts curious about their listening habits.

Demonstrates SQL skills in data cleaning, aggregation, and trend analysis.
