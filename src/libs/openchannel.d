module src.libs.openchannel;

class OpenChannel 
{
    /** ****************************************
    * Constants
    ***************************************** */
    const double GRAVITY_METRIC = 9.81;
    const double DEPTH_TRIAL_INCREMENT = 0.00001;
    const double SLOPE_TRIAL_INCREMENT = 0.0000001;

    /** ****************************************
    * Properties
    ***************************************** */
    public enum FlowType {
        CRITICAL,
        SUBCRITICAL,
        SUPERCRITICAL
    }

    /// Discharge / Flow Rate
    double discharge;

    protected double bedSlope;

    protected double waterDepth;

    protected float manningRoughness;

    protected double wettedPerimeter;

    protected double wettedArea;

    protected double hydraulicRadius;

    protected double averageVelocity;

    protected float froudeNumber;

    protected FlowType flowType;

    protected double hydraulicDepth;
    protected double dischargeIntensity;
    protected double criticalDepth;
    protected double criticalSlope;

    protected bool isCalculationSuccess;
    protected string errorMessage;

    /** ****************************************
    * Getters
    ***************************************** */

    public double getDischarge() {
        return discharge;
    }

    public double getAverageVelocity() {
        return averageVelocity;
    }

    public double getBedSlope() {
        return bedSlope;
    }

    public double getWaterDepth() {
        return waterDepth;
    }

    public double getWettedPerimeter() {
        return wettedPerimeter;
    }

    public double getWettedArea() {
        return wettedArea;
    }

    public double getHydraulicRadius() {
        return hydraulicRadius;
    }

    public double getFroudeNumber() {
        return froudeNumber;
    }

    public double getManningRoughness() {
        return manningRoughness;
    }

    public FlowType getFlowType() {
        return flowType;
    }

    public double getHydraulicDepth() {
        return hydraulicDepth;
    }

    public double getDischargeIntensity() {
        return dischargeIntensity;
    }

    public double getCriticalDepth() {
        return criticalDepth;
    }

    public double getCriticalSlope() {
        return criticalSlope;
    }

    /**
    * Check if an error has occurred.
    * @return isError
    */
    public bool isCalculationSuccessful() {
        return isCalculationSuccessful;
    }

    /**
    * Gets the error message.
    * @return errMessage
    */
    public string getErrMessage() {
        return errorMessage;
    }

    /** ***************************************
    * Setters
    **************************************** */
    public void setBedSlope(double pBedSlope) {
        bedSlope = pBedSlope;
    }

    public void setDischarge(double pDischarge) {
        discharge = pDischarge;
    }

    public void setWaterDepth(double pWaterDepth) {
        waterDepth = pWaterDepth;
    }

    public void setManningRoughness(double pManningRoughness) {
        manningRoughness = pManningRoughness;
    }

    /**
    * Methods
    */
    protected void calculateFlowType() {
        // Flow type
        if (this.froudeNumber == 1) {
            flowType = FlowType.CRITICAL;
        } else if (this.froudeNumber < 1) {
            flowType = FlowType.SUBCRITICAL;
        } else {
            flowType = FlowType.SUPERCRITICAL;
        }
    }

}

/**
 * A custom exception for invalid dimensions.
 */
class DimensionException : Exception {
  /**
   * Construct a {@code DimensionException} with a message parameter.
   * @param message A string description of the exception.
   */
  this(string message) {
    super(message);
  }
}

/**
 * A custom exception for handling illegal or invalid values or constants.
 */
class InvalidValueException : Exception {
  /**
   * Construct a {@code InvalidValueException} with a message parameter.
   * @param message A string description of the exception.
   */
  this(string message){
    super(message);
  }
}