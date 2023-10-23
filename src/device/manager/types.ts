export enum EPTZCMD {
  TILT_UP = 0, // on
  TILT_DOWN = 1, // down
  PAN_LEFT = 2, // Left
  PAN_RIGHT = 3, // Right
  PAN_LEFTTOP = 4, // Upper left
  PAN_LEFTDOWN = 5, // Lower left
  PAN_RIGTHTOP = 6, // Top right
  PAN_RIGTHDOWN = 7, // Lower right
  ZOOM_OUT = 8, // The number of times smaller
  ZOOM_IN = 9, // Double the size
  FOCUS_FAR = 10, // Focus back
  FOCUS_NEAR = 11, // Focus forward
  IRIS_OPEN = 12, // The aperture is enlarged
  IRIS_CLOSE = 13, // The aperture decreases by 13
  EXTPTZ_OPERATION_ALARM = 14, ///< Alarm function
  EXTPTZ_LAMP_ON = 15, ///< Lights on
  EXTPTZ_LAMP_OFF = 16, // The lights are off
  EXTPTZ_POINT_SET_CONTROL = 17, // Set the preset point
  EXTPTZ_POINT_DEL_CONTROL = 18, // Clear preset points
  EXTPTZ_POINT_MOVE_CONTROL = 19, // Go to the preset point
  EXTPTZ_STARTPANCRUISE = 20, // Start horizontal rotation
  EXTPTZ_STOPPANCRUISE = 21, // Stop horizontal rotation
  EXTPTZ_SETLEFTBORDER = 22, // Set the left boundary
  EXTPTZ_SETRIGHTBORDER = 23, // Set the right boundary
  EXTPTZ_STARTLINESCAN = 24, // Automatic scanning starts
  EXTPTZ_CLOSELINESCAN = 25, // Automatic scanning starts and stops
  EXTPTZ_ADDTOLOOP = 26, // Add preset points to cruise p1 preset points for cruise line p2
  EXTPTZ_DELFROMLOOP = 27, // Delete preset point p1 on cruise line p2
  EXTPTZ_POINT_LOOP_CONTROL = 28, // Start cruising
  EXTPTZ_POINT_STOP_LOOP_CONTROL = 29, // Stop cruising
  EXTPTZ_CLOSELOOP = 30, // Clear the cruise p1 cruise line
  EXTPTZ_FASTGOTO = 31, // Fast positioning
  EXTPTZ_AUXIOPEN = 32, // Auxiliary switch, off in the subcommand
  EXTPTZ_OPERATION_MENU = 33, // Ball machine menu operation, including on, off, OK, etc
  EXTPTZ_REVERSECOMM = 34, // Lens flip
  EXTPTZ_OPERATION_RESET = 35, ///< Head reset
  EXTPTZ_TOTAL = 36,
}

export type DeviceManagerPromiseSuccessType = {
  s: string;
  i: number;
};

export type DeviceIdParams = {
  deviceId: string;
};

export type DeviceCredentialParams = {
  deviceId: string;
  deviceLogin: string;
  devicePassword: string;
};
