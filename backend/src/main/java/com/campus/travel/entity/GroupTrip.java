package com.campus.travel.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class GroupTrip {
    private Long id;
    private String groupNo;
    private Long creatorUserId;
    private String organizerType;
    private String title;
    private String tripCategory;
    private String highlightsRichtext;
    private String gatherLocation;
    private String destination;
    @com.fasterxml.jackson.annotation.JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime startTime;
    @com.fasterxml.jackson.annotation.JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime signupDeadline;
    private Integer minMemberCount;
    private Integer maxMemberCount;
    private Integer currentMemberCount;
    private BigDecimal budgetPerPerson;
    private BigDecimal depositAmount;
    private String groupStatus;
    private LocalDateTime createdAt;
    private String creatorName; // Associated
}
