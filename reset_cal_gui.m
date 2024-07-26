function reset_cal_gui(app)

cla(app.UIAxesDataLeft)
cla(app.UIAxesDataRight)
% reset computed coefficients
app.Coeff_1_LeftEditField.Value = 0;
app.Coeff_2_LeftEditField.Value = 0;
app.Coeff_1_RightEditField.Value = 0;
app.Coeff_2_RightEditField.Value = 0;
% reset saved file field
app.SavedCoefficientsEditField.Value = '';
% reset checkboxes
app.RightAdjusttimeintervaltouseCheckBox.Value = 0;
app.LeftAdjusttimeintervaltouseCheckBox.Value = 0;

end