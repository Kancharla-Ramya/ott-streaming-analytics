import streamlit as st
import pandas as pd
import plotly.express as px
import seaborn as sns
import matplotlib.pyplot as plt

# ============================================================
# PAGE CONFIG
# ============================================================

st.set_page_config(
    page_title="OTT Streaming Platform Dashboard",
    page_icon="📺",
    layout="wide"
)

st.title("📺 OTT Streaming Platform Viewing Analysis Dashboard")

st.markdown(
    """
    This dashboard analyses user demographics, viewing behaviour,
    content performance, subscriptions, churn, ratings and feedback
    across the OTT streaming platform datasets.
    """
)

# ============================================================
# LOAD ALL 5 CLEANED DATASETS
# ============================================================

@st.cache_data
def load_data():

    user_profile = pd.read_excel(
        r"C:\Users\ramya\OneDrive\Desktop\PR\project-topic-05-main\Cleaned_Data\user_profile_cleaned.xlsx"
    )

    content_library = pd.read_excel(
        r"C:\Users\ramya\OneDrive\Desktop\PR\project-topic-05-main\Cleaned_Data\content_library_cleaned.xlsx"
    )

    viewing_activity = pd.read_excel(
        r"C:\Users\ramya\OneDrive\Desktop\PR\project-topic-05-main\Cleaned_Data\viewing_activity_cleaned.xlsx"
    )

    subscription_retention = pd.read_excel(
        r"C:\Users\ramya\OneDrive\Desktop\PR\project-topic-05-main\Cleaned_Data\subscription_retention_cleaned.xlsx"
    )

    ratings_feedback = pd.read_excel(
        r"C:\Users\ramya\OneDrive\Desktop\PR\project-topic-05-main\Cleaned_Data\ratings_feedback_cleaned.xlsx"
    )

    return (
        user_profile,
        content_library,
        viewing_activity,
        subscription_retention,
        ratings_feedback
    )


(
    user_profile,
    content_library,
    viewing_activity,
    subscription_retention,
    ratings_feedback
) = load_data()


# ============================================================
# CREATE MASTER DATASETS USING MERGE
# ============================================================

viewing_master = viewing_activity.merge(
    user_profile[
        [
            "User_ID",
            "Gender",
            "Age_Group",
            "Region",
            "Subscription_Type",
            "Engagement_Level"
        ]
    ],
    on="User_ID",
    how="left"
)

viewing_master = viewing_master.merge(
    content_library[
        [
            "Content_ID",
            "Title",
            "Content_Type",
            "Genres",
            "Platform"
        ]
    ],
    on="Content_ID",
    how="left"
)


user_retention = user_profile.merge(
    subscription_retention,
    on="User_ID",
    how="left",
    suffixes=("_Profile", "_Retention")
)


rating_master = ratings_feedback.merge(
    content_library[
        [
            "Content_ID",
            "Title",
            "Content_Type",
            "Genres",
            "Platform"
        ]
    ],
    on="Content_ID",
    how="left"
)


# ============================================================
# SIDEBAR FILTERS
# ============================================================

st.sidebar.header("🔎 Dashboard Filters")


platform_list = sorted(
    viewing_master["Platform"].dropna().unique()
)

selected_platform = st.sidebar.multiselect(
    "Platform",
    platform_list,
    default=platform_list
)


age_list = sorted(
    viewing_master["Age_Group"].dropna().unique()
)

selected_age = st.sidebar.multiselect(
    "Age Group",
    age_list,
    default=age_list
)


gender_list = sorted(
    viewing_master["Gender"].dropna().unique()
)

selected_gender = st.sidebar.multiselect(
    "Gender",
    gender_list,
    default=gender_list
)


device_list = sorted(
    viewing_master["Device_Type"].dropna().unique()
)

selected_device = st.sidebar.multiselect(
    "Device Type",
    device_list,
    default=device_list
)


content_type_list = sorted(
    viewing_master["Content_Type"].dropna().unique()
)

selected_content_type = st.sidebar.multiselect(
    "Content Type",
    content_type_list,
    default=content_type_list
)


# ============================================================
# APPLY FILTERS
# ============================================================

filtered_viewing = viewing_master[
    (viewing_master["Platform"].isin(selected_platform))
    &
    (viewing_master["Age_Group"].isin(selected_age))
    &
    (viewing_master["Gender"].isin(selected_gender))
    &
    (viewing_master["Device_Type"].isin(selected_device))
    &
    (viewing_master["Content_Type"].isin(selected_content_type))
]


# ============================================================
# KPI CARDS
# ============================================================

st.subheader("📊 Key Performance Indicators")

col1, col2, col3, col4, col5 = st.columns(5)


with col1:

    total_users = filtered_viewing["User_ID"].nunique()

    st.metric(
        "Active Users",
        f"{total_users:,}"
    )


with col2:

    total_views = filtered_viewing["Viewing_Record_ID"].count()

    st.metric(
        "Viewing Records",
        f"{total_views:,}"
    )


with col3:

    total_watch_hours = (
        filtered_viewing["Watch_Duration_Minutes"].sum() / 60
    )

    st.metric(
        "Watch Hours",
        f"{total_watch_hours:,.0f}"
    )


with col4:

    avg_completion = filtered_viewing[
        "Completion_Percentage"
    ].mean()

    st.metric(
        "Avg Completion",
        f"{avg_completion:.1f}%"
    )


with col5:

    avg_rating = ratings_feedback["Rating"].mean()

    st.metric(
        "Average Rating",
        f"{avg_rating:.2f}/5"
    )


# ============================================================
# BUSINESS QUESTION 1
# PLATFORM PERFORMANCE
# ============================================================

st.subheader(
    "1️⃣ Which OTT platform generates the highest viewer engagement?"
)

platform_summary = (
    filtered_viewing
    .groupby("Platform")
    .agg(
        Total_Views=("Viewing_Record_ID", "count"),
        Watch_Minutes=("Watch_Duration_Minutes", "sum"),
        Avg_Completion=("Completion_Percentage", "mean")
    )
    .reset_index()
)

platform_summary["Watch_Hours"] = (
    platform_summary["Watch_Minutes"] / 60
)


fig = px.bar(
    platform_summary,
    x="Platform",
    y="Watch_Hours",
    color="Platform",
    text_auto=".2s",
    title="Total Watch Hours by OTT Platform"
)

st.plotly_chart(
    fig,
    use_container_width=True
)

st.info(
    """
    Narration:
    This visualization compares total viewer engagement across OTT
    platforms using watch hours. Platforms with higher watch hours
    are generating stronger overall audience engagement.
    """
)


# ============================================================
# BUSINESS QUESTION 2
# CONTENT TYPE PERFORMANCE
# ============================================================

st.subheader(
    "2️⃣ Do Movies or TV Shows generate stronger engagement?"
)

content_type_summary = (
    filtered_viewing
    .groupby("Content_Type")
    .agg(
        Total_Views=("Viewing_Record_ID", "count"),
        Watch_Minutes=("Watch_Duration_Minutes", "sum"),
        Avg_Completion=("Completion_Percentage", "mean")
    )
    .reset_index()
)

content_type_summary["Watch_Hours"] = (
    content_type_summary["Watch_Minutes"] / 60
)


fig = px.bar(
    content_type_summary,
    x="Content_Type",
    y=["Total_Views", "Watch_Hours"],
    barmode="group",
    title="Movies vs TV Shows: Views and Watch Hours"
)

st.plotly_chart(
    fig,
    use_container_width=True
)

st.info(
    """
    Narration:
    Views measure traffic volume while watch hours represent depth
    of engagement. Comparing both metrics helps determine whether
    Movies or TV Shows create stronger audience consumption.
    """
)


# ============================================================
# BUSINESS QUESTION 3
# AGE GROUP ENGAGEMENT
# ============================================================

st.subheader(
    "3️⃣ Which age group shows the strongest viewing engagement?"
)


age_summary = (
    filtered_viewing
    .groupby("Age_Group")
    .agg(
        Total_Views=("Viewing_Record_ID", "count"),
        Avg_Watch_Duration=("Watch_Duration_Minutes", "mean"),
        Avg_Completion=("Completion_Percentage", "mean")
    )
    .reset_index()
)


fig = px.bar(
    age_summary,
    x="Age_Group",
    y="Avg_Watch_Duration",
    color="Age_Group",
    title="Average Watch Duration by Age Group"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


st.info(
    """
    Narration:
    The chart shows how viewing behaviour varies across age groups.
    Age segments with higher average watch duration represent more
    engaged audience groups and can support targeted content strategy.
    """
)


# ============================================================
# BUSINESS QUESTION 4
# DEVICE PERFORMANCE
# ============================================================

st.subheader(
    "4️⃣ Which device type produces the highest completion rate?"
)


device_summary = (
    filtered_viewing
    .groupby("Device_Type")
    ["Completion_Percentage"]
    .mean()
    .reset_index()
)


fig = px.bar(
    device_summary,
    x="Device_Type",
    y="Completion_Percentage",
    color="Device_Type",
    title="Average Completion Percentage by Device"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


st.info(
    """
    Narration:
    Completion percentage indicates how consistently users finish
    the content they start. Device-level differences can help identify
    where audiences demonstrate stronger viewing engagement.
    """
)


# ============================================================
# BUSINESS QUESTION 5
# TIME OF DAY ANALYSIS
# ============================================================

st.subheader(
    "5️⃣ At what time of day is viewer engagement highest?"
)


time_summary = (
    filtered_viewing
    .groupby("Time_of_Day")
    .agg(
        Total_Views=("Viewing_Record_ID", "count"),
        Avg_Completion=("Completion_Percentage", "mean"),
        Watch_Minutes=("Watch_Duration_Minutes", "sum")
    )
    .reset_index()
)


fig = px.bar(
    time_summary,
    x="Time_of_Day",
    y="Total_Views",
    color="Time_of_Day",
    title="Viewing Activity by Time of Day"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


st.info(
    """
    Narration:
    This analysis identifies peak OTT consumption periods.
    Understanding when users watch content can help schedule new
    releases, promotions and personalized recommendations.
    """
)


# ============================================================
# BUSINESS QUESTION 6
# TOP CONTENT
# ============================================================

st.subheader(
    "6️⃣ Which content titles generate the most viewing activity?"
)


top_content = (
    filtered_viewing
    .groupby(
        [
            "Content_ID",
            "Title",
            "Platform",
            "Content_Type"
        ]
    )
    .agg(
        Total_Views=("Viewing_Record_ID", "count"),
        Watch_Minutes=("Watch_Duration_Minutes", "sum")
    )
    .reset_index()
)


top_content["Watch_Hours"] = (
    top_content["Watch_Minutes"] / 60
)


top_content = (
    top_content
    .sort_values(
        "Total_Views",
        ascending=False
    )
    .head(10)
)


fig = px.bar(
    top_content.sort_values("Total_Views"),
    x="Total_Views",
    y="Title",
    orientation="h",
    color="Platform",
    title="Top 10 Most Viewed Content Titles"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


st.info(
    """
    Narration:
    The chart highlights the content titles attracting the highest
    number of viewing records. These titles represent strong audience
    demand and can guide future acquisition and recommendation decisions.
    """
)


# ============================================================
# BUSINESS QUESTION 7
# GENRE PERFORMANCE
# ============================================================

st.subheader(
    "7️⃣ Which genres attract the most viewers?"
)


genre_data = filtered_viewing.copy()

genre_data["Genres"] = (
    genre_data["Genres"]
    .fillna("Unknown")
    .str.split(",")
)


genre_data = genre_data.explode("Genres")

genre_data["Genres"] = (
    genre_data["Genres"]
    .str.strip()
)


genre_summary = (
    genre_data
    .groupby("Genres")
    .agg(
        Total_Views=("Viewing_Record_ID", "count"),
        Watch_Minutes=("Watch_Duration_Minutes", "sum")
    )
    .reset_index()
)


genre_summary["Watch_Hours"] = (
    genre_summary["Watch_Minutes"] / 60
)


top_genres = (
    genre_summary
    .sort_values(
        "Total_Views",
        ascending=False
    )
    .head(10)
)


fig = px.bar(
    top_genres.sort_values("Total_Views"),
    x="Total_Views",
    y="Genres",
    orientation="h",
    title="Top 10 Genres by Viewing Records"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


st.info(
    """
    Narration:
    Genre demand reveals the content categories preferred by the
    audience. High-performing genres can support investment,
    recommendation and acquisition decisions.
    """
)


# ============================================================
# BUSINESS QUESTION 8
# CHURN BY SUBSCRIPTION TYPE
# ============================================================

st.subheader(
    "8️⃣ Which subscription type has the highest churn risk?"
)


churn_summary = (
    subscription_retention
    .groupby("Subscription_Type")
    .agg(
        Total_Users=("User_ID", "count"),
        Churned_Users=("Churn_Flag", "sum"),
        Churn_Rate=("Churn_Flag", "mean")
    )
    .reset_index()
)


churn_summary["Churn_Rate"] = (
    churn_summary["Churn_Rate"] * 100
)


fig = px.bar(
    churn_summary,
    x="Subscription_Type",
    y="Churn_Rate",
    color="Subscription_Type",
    text_auto=".2f",
    title="Churn Rate by Subscription Type"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


st.info(
    """
    Narration:
    Churn rate measures the percentage of users leaving each
    subscription plan. Plans with high churn require stronger
    retention strategies, engagement offers or pricing interventions.
    """
)


# ============================================================
# BUSINESS QUESTION 9
# RATINGS AND FEEDBACK
# ============================================================

st.subheader(
    "9️⃣ How satisfied are viewers with the content?"
)


col1, col2 = st.columns(2)


with col1:

    rating_summary = (
        ratings_feedback["Rating"]
        .value_counts()
        .sort_index()
        .reset_index()
    )

    rating_summary.columns = [
        "Rating",
        "Count"
    ]


    fig = px.bar(
        rating_summary,
        x="Rating",
        y="Count",
        title="Viewer Rating Distribution"
    )

    st.plotly_chart(
        fig,
        use_container_width=True
    )


with col2:

    feedback_summary = (
        ratings_feedback["Feedback_Category"]
        .value_counts()
        .reset_index()
    )

    feedback_summary.columns = [
        "Feedback_Category",
        "Count"
    ]


    fig = px.pie(
        feedback_summary,
        names="Feedback_Category",
        values="Count",
        hole=0.45,
        title="Feedback Category Distribution"
    )

    st.plotly_chart(
        fig,
        use_container_width=True
    )


st.info(
    """
    Narration:
    Ratings and feedback provide direct evidence of user satisfaction.
    Positive feedback and higher ratings indicate stronger content
    acceptance, while negative feedback highlights improvement areas.
    """
)


# ============================================================
# BUSINESS QUESTION 10
# WATCH DURATION VS COMPLETION
# ============================================================

st.subheader(
    "🔟 Is watch duration related to content completion?"
)


scatter_data = filtered_viewing.sample(
    min(5000, len(filtered_viewing)),
    random_state=42
)


fig = px.scatter(
    scatter_data,
    x="Watch_Duration_Minutes",
    y="Completion_Percentage",
    color="Content_Type",
    opacity=0.5,
    title="Watch Duration vs Completion Percentage"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


correlation = filtered_viewing[
    [
        "Watch_Duration_Minutes",
        "Completion_Percentage"
    ]
].corr().iloc[0, 1]


st.write(
    f"Correlation between Watch Duration and Completion Percentage: "
    f"**{correlation:.3f}**"
)


st.info(
    """
    Narration:
    The scatter plot tests whether longer watch durations are associated
    with higher completion percentages. A weak relationship indicates
    that watch duration alone does not fully explain completion behaviour.
    """
)


# ============================================================
# CORRELATION HEATMAP
# ============================================================

st.subheader("🔥 Viewing Behaviour Correlation Heatmap")


numeric_columns = [
    "Watch_Duration_Minutes",
    "Completion_Percentage",
    "Paused_Times"
]


corr = filtered_viewing[
    numeric_columns
].corr()


fig, ax = plt.subplots(
    figsize=(8, 5)
)


sns.heatmap(
    corr,
    annot=True,
    cmap="coolwarm",
    fmt=".2f",
    ax=ax
)


st.pyplot(fig)


# ============================================================
# USER PROFILE ANALYSIS
# ============================================================

st.subheader("👥 User Profile Analysis")


col1, col2 = st.columns(2)


with col1:

    region_summary = (
        user_profile["Region"]
        .value_counts()
        .reset_index()
    )

    region_summary.columns = [
        "Region",
        "Users"
    ]


    fig = px.bar(
        region_summary,
        x="Region",
        y="Users",
        title="Users by Region"
    )

    st.plotly_chart(
        fig,
        use_container_width=True
    )


with col2:

    engagement_summary = (
        user_profile["Engagement_Level"]
        .value_counts()
        .reset_index()
    )

    engagement_summary.columns = [
        "Engagement_Level",
        "Users"
    ]


    fig = px.pie(
        engagement_summary,
        names="Engagement_Level",
        values="Users",
        hole=0.4,
        title="User Engagement Level"
    )

    st.plotly_chart(
        fig,
        use_container_width=True
    )


# ============================================================
# CONTENT LIBRARY ANALYSIS
# ============================================================

st.subheader("🎬 Content Library Analysis")


content_platform_summary = (
    content_library
    .groupby(
        [
            "Platform",
            "Content_Type"
        ]
    )
    .size()
    .reset_index(
        name="Content_Count"
    )
)


fig = px.bar(
    content_platform_summary,
    x="Platform",
    y="Content_Count",
    color="Content_Type",
    barmode="group",
    title="Content Library by Platform and Content Type"
)

st.plotly_chart(
    fig,
    use_container_width=True
)


# ============================================================
# SUBSCRIPTION AND RETENTION ANALYSIS
# ============================================================

st.subheader("💳 Subscription & Retention Summary")


subscription_summary = (
    subscription_retention
    .groupby("Subscription_Type")
    .agg(
        Users=("User_ID", "count"),
        Avg_Monthly_Fee=("Monthly_Fee", "mean"),
        Churn_Rate=("Churn_Flag", "mean")
    )
    .reset_index()
)


subscription_summary["Churn_Rate"] = (
    subscription_summary["Churn_Rate"] * 100
)


st.dataframe(
    subscription_summary,
    use_container_width=True
)


# ============================================================
# RATINGS SUMMARY
# ============================================================

st.subheader("⭐ Rating Summary")


rating_content_summary = (
    rating_master
    .groupby(
        [
            "Platform",
            "Content_Type"
        ]
    )
    .agg(
        Ratings=("Rating", "count"),
        Average_Rating=("Rating", "mean")
    )
    .reset_index()
)


st.dataframe(
    rating_content_summary,
    use_container_width=True
)


# ============================================================
# VIEWING SUMMARY TABLE
# ============================================================

st.subheader("📋 Platform Viewing Summary")


platform_table = (
    filtered_viewing
    .groupby("Platform")
    .agg(
        Viewing_Records=("Viewing_Record_ID", "count"),
        Unique_Users=("User_ID", "nunique"),
        Total_Watch_Minutes=("Watch_Duration_Minutes", "sum"),
        Avg_Watch_Duration=("Watch_Duration_Minutes", "mean"),
        Avg_Completion=("Completion_Percentage", "mean")
    )
    .reset_index()
)


platform_table["Total_Watch_Hours"] = (
    platform_table["Total_Watch_Minutes"] / 60
)


platform_table = platform_table[
    [
        "Platform",
        "Viewing_Records",
        "Unique_Users",
        "Total_Watch_Hours",
        "Avg_Watch_Duration",
        "Avg_Completion"
    ]
]


st.dataframe(
    platform_table.round(2),
    use_container_width=True
)


# ============================================================
# DATASET PREVIEW
# ============================================================

st.subheader("📂 Dataset Preview")


dataset_choice = st.selectbox(
    "Select Dataset",
    [
        "User Profile",
        "Content Library",
        "Viewing Activity",
        "Subscription Retention",
        "Ratings Feedback"
    ]
)


if dataset_choice == "User Profile":

    st.dataframe(
        user_profile.head(100),
        use_container_width=True
    )


elif dataset_choice == "Content Library":

    st.dataframe(
        content_library.head(100),
        use_container_width=True
    )


elif dataset_choice == "Viewing Activity":

    st.dataframe(
        viewing_activity.head(100),
        use_container_width=True
    )


elif dataset_choice == "Subscription Retention":

    st.dataframe(
        subscription_retention.head(100),
        use_container_width=True
    )


else:

    st.dataframe(
        ratings_feedback.head(100),
        use_container_width=True
    )


# ============================================================
# DOWNLOAD FILTERED DATA
# ============================================================

st.subheader("⬇️ Download Filtered Viewing Data")


csv = filtered_viewing.to_csv(
    index=False
)


st.download_button(
    label="Download Filtered OTT Data",
    data=csv,
    file_name="filtered_ott_viewing_data.csv",
    mime="text/csv"
)


# ============================================================
# END
# ============================================================

st.success(
    "OTT Streaming Platform Dashboard Loaded Successfully 📺"
)

