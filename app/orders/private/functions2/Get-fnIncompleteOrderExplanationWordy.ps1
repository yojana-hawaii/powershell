function Get-fnIncompleteOrderExplanationWordy {
    return "<p><b>Consult</b>
            <ul>
                <li>Excludes consult within 42 days of order. Shows up in this list after 42 days if the result is not received.</li>
                <li>Excludes expired consult. 365 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Lab</b>
            <ul>
                <li>Excludes lab within 7 days of order. Shows up in this list after 7 days if the result is not received.</li>
                <li>Excludes expired labs. 180 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Imaging</b>
            <ul>
                <li>Excludes imaging within 30 days of order. Shows up in this list after 30 days if the result is not received.</li>
                <li>Excludes expired imaging. 180 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Procedures</b>
            <ul>
                <li>Excludes procedures within 14 days of order. Shows up in this list after 14 days if the result is not received.</li>
                <li>Excludes expired procedures. 365 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p><b>Other</b>
            <ul>
                <li>Excludes 'other' orders within 7 days of order. Shows up in this list after 7 days if the result is not received.</li>
                <li>Excludes expired 'other' orders. 365 days after order </li>
                <li>Document all patient contact directly on 'order/s' (voicemail left, appt scheduled). Patient will be removed from the list for 2 weeks following documentation</li>
            </ul>

            <p>"
}