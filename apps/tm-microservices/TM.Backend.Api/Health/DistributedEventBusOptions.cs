﻿namespace TM.Backend.Api.Health
{
    public class DistributedEventBusOptions
    {
        public string StoreName { get; set; }
        public string PubSubName { get; set; }

        public string Postfix { get; set; }

        public string Prefix { get; set; }
    }
}
