package com.campus.travel.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class CarpoolTrip {
    private Long id;
    private String tripNo;
    private Long driverUserId;
    private Long vehicleId;
    private String startLocation;
    private BigDecimal startLng;
    private BigDecimal startLat;
    private String endLocation;
    private BigDecimal endLng;
    private BigDecimal endLat;
    @com.fasterxml.jackson.annotation.JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime departureTime;
    private Integer seatTotal;
    private Integer seatAvailable;
    private String pricingMode;
    private BigDecimal pricePerPerson;
    private BigDecimal depositAmount;
    private String tripStatus;
    private LocalDateTime createdAt;
    private String driverName; // Associated field
}
